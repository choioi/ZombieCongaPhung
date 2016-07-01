//
//  GameScene.swift
//  ZombieCongaPhung
//
//  Created by phung on 6/22/16.
//  Copyright (c) 2016 phung. All rights reserved.
// 29/06 Update den doan xoay

import SpriteKit

class GameScene: SKScene {
    
    
    
    
    
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    let playableRect:CGRect
    //2 tham số để tính thời gian chạy 2 hàm update()
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0 // thời gian giữa các frame
    
    //2 Tham số để khai báo khoảng cách đi được trong 1 khoảng thời gian của zombie
    let zombieMovePointsPerSec:CGFloat = 240.0 // khai báo vận tốc mỗi giây
    var velocity = CGPointZero // xác định vận tốc và hướng di chuyển, ko có điểm kết thúc hoặc bắt đầu
    
    
    //Challenge 2: Stop that zombie!
    var lastTouchLocation = CGPointZero //Ghi nhận vị trí chạm cuối cùng để khi zombie đi tới toạ độ này thì nó sẽ làm 1 hành động gì đó, stop chẳng hạn
    
    //Challenge 3: Zombie xoay mặt mượt mà từ từ
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
    
    let zombieAnimation: SKAction
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3 
        playableRect = CGRect(x: 0, y: playableMargin,
        width: size.width,
        height: playableHeight) // 4
        
        //tạo animation cho NODE 
        // 1 : tạo mảng chứa các texture để animation trong mảng này
        var textures = [SKTexture]() // 2 : Thêm textutres vào mảng 
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        // 3 This adds frames 3 and 2 to the list (remember, the textures array is 0 based). In total, the textures array now contains the frames in this order: 1, 2, 3, 4, 3, 2. The idea is you will loop this over and over for a continuous animation.
        textures.append(textures[2])
        textures.append(textures[1])
        
        // 4 Once you have the array of textures, running the animation is easy—you just create and run an action with animateWithTextures(timePerFrame:).
        zombieAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.1))
        
        
        super.init(size: size) // 5
        
        
        
    }
    required init(coder aDecoder: NSCoder) {
    
            fatalError("init(coder:) has not been implemented") // 6
    }
    
    
    //Ham nay ve khung playable cua zombie
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
     
       
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()//thiết lập nền trắng
        
        let background = SKSpriteNode(imageNamed: "background1") //node hình làm background
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)// mặc định về ở tâm
        background.zRotation = 0*CGFloat(M_PI)/180 //xoay 0 độ
        background.zPosition = -1 //background nên set -1 để khỏi che các node mặc định là 0
        addChild(background)
        
        
        //zombie.SKSpriteNode(imageNamed: "zombie")
        
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.anchorPoint = CGPoint(x: 0.5, y: 0.5)// mặc định về ở tâm
        zombie.zRotation = 0*CGFloat(M_PI)/180 //xoay 0 độ
        zombie.zPosition = 0 //background nên set -1 để khỏi che các node mặc định là 0
        //zombie.xScale = 2
        //zombie.yScale = 2
        //zombie.setScale(2) // tăng kích thước lên 2 lần, xem thêm hàm setscale của SKnode
        addChild(zombie)
        //Animation action
        //Hàm này đi hoài dù zombie dùng, nên phải dùng hàm check nếu nó stop moving thì stop animation
        //zombie.runAction(SKAction.repeatActionForever(zombieAnimation))
        
        //This runs the action wrapped in a repeat forever action. This will seamlessly cycle through the frames 1,2,3,4,3,2,1,2,3,4,3,2,1,2....
        
        
        let backgroundSize = background.size // Lấy size, width,height của 1 đối tượng
        let zombieSize = zombie.size
        print("backgroundSize: \(backgroundSize)")
        print("zombieSize: \(zombieSize)")
        debugDrawPlayableArea()
        
        //spawnEnemy() liên tục enemy, sau đó chờ 2s spawm tiếp, vì cứ mỗi con enemy trong action nó đã tốn 2s để đi hết đạon đường, nên chờ 2s để spawm tiếp con khác
        //Note that you’re running the action on the scene itself. This works because the scene is a node, and any node can run actions.
        //gọi hàm action trực tiếp trên scene có thể dùng self.runaction hoặc trực tiếp gọi Runaction như sau :
        
        //self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy),SKAction.waitForDuration(2.0)])))
        
        //hoặc
        
        //runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy),SKAction.waitForDuration(2.0)])))
        //Tuy nhiên dòng trên thì zombie sẽ chạy hoài lien tục, dù cho con ziombie có đứng yên, nên ta phải gọi hàm startnamation va stop để nó tự biết khi nào nên stop
        startZombieAnimation()
        //spawm meo con
        runAction(SKAction.repeatActionForever( SKAction.sequence([SKAction.runBlock(spawnCat),
            SKAction.waitForDuration(1.0)])))
        
    }
    
    //Stopping action : Bạn phải stop animation khi zombie đứng yên
    //Trong Sprite Kit, khi bạn chạy 1 action , bạn có thể gán 1 cho anamition đó 1 key gọi là runAction(withKey:). Với cách này bạn có thể ngưng anammation với hàm removeActionForKey().
    //Add 2 hàm này để giải quyết vấn đề này: startZombieAnimation và stopZombieAnimation
    
    func startZombieAnimation() {
        if zombie.actionForKey("zombiebuocdi") == nil {
        zombie.runAction(SKAction.repeatActionForever(zombieAnimation),withKey: "zombiebuocdi")
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeActionForKey("zombiebuocdi")
    }
    
    
    //Spawm meo
    
    func spawnCat() { // 1
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.position = CGPoint(x: CGFloat.random(CGRectGetMinX(playableRect), max: CGRectGetMaxX(playableRect)),y: CGFloat.random(CGRectGetMinY(playableRect), max: CGRectGetMaxY(playableRect)))
        cat.setScale(0)
        addChild(cat)
        // 2
            cat.zRotation = -π / 16.0
            let leftWiggle = SKAction.rotateByAngle(π/8.0, duration: 0.5)
            let rightWiggle = leftWiggle.reversedAction()
            let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
            let wiggleWait = SKAction.repeatAction(fullWiggle, count: 10) // chuỗi action cho con mèo quay tới quay lui, quay trái, quai phải, lặp lại 10 lần
            
        //Group action : Sử dụng multitask đa luồng : Đối với loại này đa nhiệm, bạn có thể sử dụng những gì được gọi là hành động nhóm. Nó hoạt động theo một cách tương tự như hành động sequen tuần tự, nơi bạn vượt action một danh sách các hành động. Tuy nhiên, thay vì chạy chúng cùng một thời gian lần lượt, một hành động nhóm chạy chúng cùng một lúc.
            
            let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
            let scaleDown = scaleUp.reversedAction()
            let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
            let group = SKAction.group([fullScale, fullWiggle])
            let groupWait = SKAction.repeatAction(group, count: 10)
        
            
            let appear = SKAction.scaleTo(1.0, duration: 0.5)
        //let wait = SKAction.waitForDuration(10.0) // Thay thế wait ngồi yên bằng 1 chuỗi action quay tối quay lui
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
     
       // let actions = [appear, wiggleWait, disappear, removeFromParent] // Hãy nhìn những con mèo, đều giống nhau. quay giống nhau..Mình muốn nó random nên phải group nó multi chạy độc lập
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(actions))
    }
    
    
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
         moveZombieToward(touchLocation)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let location = touch.locationInNode(self)
        
        sceneTouched(location)// co the goi truc tiep hàm moveZombieToward(touch) luon
           
    }
        
        
    
    }
    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        <#code#>
//    }

    func boundsCheckZombie() {
        
        //1: vung di chuyen gioi han trong khung playableRect
        let bottomLeft = CGPoint(x: 0,y: CGRectGetMinY(playableRect)) //Lay Min Y
        let topRight = CGPoint(x: size.width,y: CGRectGetMaxY(playableRect)) //lay Max Y
        
        //2: Vung di chuyen phu hop voi man hinh thiet bi
       // let bottomLeft = CGPointZero
        //let topRight = CGPoint(x: size.width, y: size.height)
        
        
        //Nếu vị trí x của zombie đi vượt quá cạnh trái màn hình, thì gán lại vị trí x cùa màn hình = vị trị cua zombie, chuyển hướng x của hướng di chuyển ngược lại, nghĩa là đụng tường dội lại
        if zombie.position.x <= bottomLeft.x {
        zombie.position.x = bottomLeft.x
        velocity.x = -velocity.x
        }
        
        //Nếu vị trí x của zombie đi vượt quá cạnh phải, thì gán lai vị trí x của zombie bằng vị trí x của cạnh phải, đồng thời chuyển hướng di chuyển về phía ngược lại, nghĩa là đụng tường dội lại
        if zombie.position.x >= topRight.x {
        zombie.position.x = topRight.x
        velocity.x = -velocity.x }
        
        //Nếu zombie đi xuống dưới và vượt quá cạnh dưới màn hình, thì gán lại vị trí y canh dưới cùa màn hình = vị trị y của  zombie, chuyển hướng y của hướng di chuyển ngược lại, nghĩa là đụng tường dội lại
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        
         //Nếu zombie đi lên trên và vượt quá cạnh trên màn hình, thì gán lại vị trí y canh trên cùa màn hình = vị trị y của  zombie, chuyển hướng y của hướng di chuyển ngược lại, nghĩa là đụng tường dội lại
        if zombie.position.y >= topRight.y {
        zombie.position.y = topRight.y
        velocity.y = -velocity.y }
    }
    
    
    //Hàm xoay mặt, truyền node cần xoay và hướng xoay
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        //sprite.zRotation = CGFloat(atan2(Double(direction.y), Double(direction.x)))
        let shortestAngle = shortestAngleBetween(zombie.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortestAngle))
        sprite.zRotation += shortestAngle.sign() * amountToRotate
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered
        Mỗi frame chạy thì hàm này gọi 1 lần*/
        //Mỗi frame chạy sẽ move con zommbie qua phải 1 đoạn la 4
        
        // Kiểm tra thời gian mỗi frame cách nhau bao nhiêu
        //Khai báo ở gamescene 2 biến này để gọi
        //var lastUpdateTime: NSTimeInterval = 0
        //var dt: NSTimeInterval = 0

        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0}
        lastUpdateTime = currentTime
        //print("\(dt*1000) milliseconds since last update")

        //cách 1 : Cập nhật lại vị trí của zombie mỗi frame. cách cơ bản nhưng chuối, ví ko thể truyền 2 tham số cố định, cái này chỉ để test
        //zombie.position = CGPoint(x: zombie.position.x + 4, y: zombie.position.y)
        
        
        //Cách 2 :
        
        //moveSprite(zombie,velocity: CGPoint(x: zombieMovePointsPerSec, y: 0))
        
        //cách 3 : di chuyển đến vị trí mình tap
        moveSprite(zombie, velocity: velocity)
        boundsCheckZombie()
        rotateSprite(zombie, direction: velocity,rotateRadiansPerSec: zombieRotateRadiansPerSec)
        
        //distanceCheckZombie() // Hàm này nếu muôn zombie ngừng tại ví trí mình chạm
        
        
        
//        print("last touch\(lastTouchLocation),zombie:\(zombie.position)")
//        
//        if lastTouchLocation == zombie.position {
//            print("OK ending")
//        }
        
        
        
        //print(velocity)
        }
    
    
    
    
    
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
            // 1
            //let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt)) //Thay thế dòng này bằng dòng công thức gọn hơn trong file MyUtils.swift
        let amountToMove = velocity * CGFloat(dt)
        //
           //Velocity là ở Số điểm point mỗi giây, và bạn cần phải tìm ra bao nhiêu điểm để di chuyển zombie trong mỗi frame thời gian này. Để xác định số  điểm này rằng, ta nhân vận tốc của mỗi giây, với thời gian giữa mỗi 2 frame , ta sẽ có con số chính xác nếu thời gian giữa 2 frame là bao nhiêu thì di chuyển bấy nhiêu, bất chấp thời gian giữa 2 frame này ko đều nhau , cho mỗi frame thứ hai bởi các phần nhỏ của giây kể từ khi cập nhật cuối cùng. Bây giờ bạn có một điểm đại diện cho vị trí của zombie (mà bạn cũng có thể nghĩ đến như là một vector từ gốc đến vị trí của zombie) và một vector đại diện cho khoảng cách và hướng để di chuyển các zombie khung này:
            //print("Amount to move: \(amountToMove)")
            // 2
            
        //sprite.position = CGPoint(x: sprite.position.x + amountToMove.x,y: sprite.position.y + amountToMove.y) //Thay thế dòng này bằng dòng công thức gọn hơn trong file MyUtils.swift
        
        sprite.position += amountToMove

    }

    func moveZombieToward(location: CGPoint) {
            startZombieAnimation()
            //offset : Độ lệch của x,y so với vị trí ban đầu
                //let offset = CGPoint(x: location.x - zombie.position.x,y: location.y - zombie.position.y)
                let offset = location - zombie.position
        //
        
        //lenght : Độ dài từ vị trí củ đến vị trí mới, sẽ là cạnh huyền của 1 tam giác được tạo bởi điểm củ và điểm mới, bỏ tính vì trong MyUtils đã có khai báo trong hàm normalized.
        
        //let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        
                // xác định hướng di chuyển mỗi giây, tăng x hay trừ x, tăng y hay trừ y
        
        
        //let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        //check thêm trong hàm MyUtils.swift
        
        let direction = offset.normalized()
        
        //let direction = offset / length
        //print("offset.x:\(offset.x),offset.y:\(offset.y) ,direction.x:\(direction.x),direction.y:\(direction.y), lenght: \(length)")
        
        
                //velocity = CGPoint(x: direction.x * zombieMovePointsPerSec, y: direction.y * zombieMovePointsPerSec)
                //print("velocity.x:\(velocity.x),velocity.y:\(velocity.y)")
        velocity = direction * zombieMovePointsPerSec
        
        
        
    }
    
    func distanceCheckZombie() {
        // Trong hàm update() kiểm tra khoảng cách của last touch và vị trí của zombie hiện hành, nếu khoảng cách này nhỏ hơn hoặc bằng khoảng cách của zombie sẽ di chuyển được trong frame kế tiếp(tính bằng hàm zombieMovePointsPerSec * dt ) thì thiết lập lại vị trí của zombie = vị trí last touch, và cho gia tốc về 0 , ngược lại thì vẫn cho di chuyền bình thường.
        
        //Để thực hiện điều này, dùng hàm - một lần, và hàm lenght() để tính độ dài một lần
        
        //Tính khoảng cách zombie với khoảng cách của lasttouch
        let distance = (zombie.position - lastTouchLocation).length()
        if distance > zombieMovePointsPerSec * CGFloat(dt) {
            // Nếu khoảng cách distance lớn hơn khoảng cách di chuyển được trong frame kế tiếp ( thời gian giữa 2 frame), 1 đoạn rất ngắn, tức là chưa đi đến nơi, ta cho zombie tiếp tục move!
            // Do hiện tại luôn có hàm moveSprite trong update nên nếu khoảng cách chưa đi đến ko cần thao tác gì cũng được, vì nó vẫn di chuyển, ở đây ta print để test thôi
                print("chua di chuyen den vi tri da cham")
                //moveSprite(zombie, velocity: velocity)
                //rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
              } else {
            // ngược lại cho zombie đứng yên, tại vị trí của mình chạm, gia tốc = 0
                zombie.position = lastTouchLocation
                velocity = CGPointZero
               // stopZombieAnimation()
            //rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
                print("da den noi")
                stopZombieAnimation()
              }
        
    }
    
    func spawnEnemy() {
        
        
        let enemy = SKSpriteNode(imageNamed: "enemy")
        //spawn enemy tai vi tri' o giua màn hình bên phải , y/2, x : sát góc
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: size.height/2)
        //Spawn enemy random, ngay sát màn hình, vị trí y thì random trong khoảng chiều cao của playableRect .
        
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(
            CGRectGetMinY(playableRect) + enemy.size.height/2,
            max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
        addChild(enemy)
        
        //let diemden_enemy = CGPoint(x: -enemy.size.width/2, y: enemy.position.y)
        //let actionMove = SKAction.moveTo(diemden_enemy, duration: 2.0)
        //enemy.runAction(actionMove)
        //nếu ko cần dùng lại actionmove hoặc diemden_enemy ta có thể gộp chung dùng 1 dong code duy nhất
        
        // enemy.runAction(SKAction.moveTo(CGPoint(x: -enemy.size.width/2, y: enemy.position.y), duration: 2)) //0
        
        //Moveto : di chuyển đến 1 CGPOint có x,y cụ thể
        //MovetoX,MovetoY : di chuyển thay đổi chỉ x hoặc chỉ y
        //MovebyX,MovebyY : di chuyển THÊM 1 ĐOẠN NÀO ĐÓ 
        //.waitForDuration : Wait 1 khoảng thời gian
        
        
        // Di chuyển tuần tự 2 ation kế tiếp nhau, action này trước đến action khác
        // 1
//        let actionMidMove = SKAction.moveTo( CGPoint(x: size.width/2,
//            y: CGRectGetMinY(playableRect) + enemy.size.height/2), duration: 5)
        
        //let actionMidMove = SKAction.moveByX( -size.width/2-enemy.size.width/2,
            //y: -CGRectGetHeight(playableRect)/2 + enemy.size.height/2, duration: 1.0)
        
        
        
        // 2
       //let actionMove1 = SKAction.moveTo(CGPoint(x: -enemy.size.width/2, y: enemy.position.y), duration:1.0)
        
        
        
        //let actionMove = SKAction.moveByX( -size.width/2-enemy.size.width/2,y: CGRectGetHeight(playableRect)/2 - enemy.size.height/2, duration: 1.0)
        
        // 3
        //let sequence = SKAction.sequence([actionMidMove, actionMove])
       
        
        //let wait = SKAction.waitForDuration(0.25) //4
        
        //let sequence = SKAction.sequence([actionMidMove, wait, actionMove])
        
        //Khai báo 1 biến là 1 block các hành động gì đó
//        //let logMessage = SKAction.runBlock() {
//            print("Reached bottom!")
//        }
        
        //Khai báo action reverse chạy ngược về
        
        //let reverseMid = actionMidMove.reversedAction()
        //let reverseMove = actionMove.reversedAction()
        
        
        
        //Chạy lần lượt các action move tới điểm V actionMidMove, action 1 block mã tuỳ ý ,  action wait.  action move
        //sequence1 ko thể dịch ngược vì trong chuổi action có actionMove1 gọi hàm moveto, hàm này ko support reverse => sequence1 rever sẽ chạy lỗi lung tung :D
        //let sequence1 = SKAction.sequence([actionMidMove, logMessage, wait, actionMove1])
        
        //Chay ngược về, sequence này có thê reverse vì ko có action nào phạm qui dịnh ko cho reverse
        //let sequence2 = SKAction.sequence([actionMidMove, logMessage, wait, actionMove,reverseMove, logMessage, wait, reverseMid])
        
        
//        let halfSequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove])
//        let sequence3 = SKAction.sequence([halfSequence, halfSequence.reversedAction()]) // khai báo tiến trình ngược về
        // Đoạn sequence3 này cho ta thấy rằng halfSequence này khi move tới điểm bot sẽ hiện message "Reached bottom!" sau đó mới wait, nhưng trên đường về, thì phải đợi wait xong mới show message..bởi vì hàm reverse() đảo ngược hoàn toàn theo trình tự ngược lại.
        //This is because the reversed sequence is the exact opposite of the original, unlike how you wrote the first version. Later in this chapter, you’ll read about the group action, which you could use to fix this."
        
        //let dichnguoimoveto = SKAction.sequence([sequence1,sequence1.reversedAction()])
        
        
        
        
        //Repeat action
        //let chayhoai = SKAction.repeatActionForever(sequence3)
       // enemy.runAction(sequence3)
        //enemy.runAction(dichnguoimoveto) // chay loi.. trong sequen co action
        
        
        
        //Reversed actions : ko phải action nào cũng đảo ngược lại được, xem thêm trong class SKAction,
        //Lưu ý quan trọng : 1 sequence cũng có thể đão ngược, với điều kiện sequence đó ko chứa action nào ko support reverse
        //(This simply creates a sequence of actions that moves the sprite one way, and then reverses the sequence to go back the other way.)
        // Lưu ý nếu đảo ngược 1 action, ko có hỗ trợ đảo ngược, thì nó sẽ chạy lại action đó
        
        
        //Repeat action
        
        
        //Hiện tại chỉ spawn enemy tại 1 ví trí , nên ta phải 
        //Periodic spawning : Spawn định kỳ
        
        
        let actionMove =
        SKAction.moveToX(-enemy.size.width/2, duration: 2.0)
        
        
        //Remove from parent action
        
        let actionRemove = SKAction.removeFromParent()
        //enemy.runAction(actionMove)
       
        //Sao khi spawm xong run actionMove xong thi remove nó, chống tràn memory
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
        
        
        

        
    }
    
    
    
     
}

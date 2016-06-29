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
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3 
        playableRect = CGRect(x: 0, y: playableMargin,
        width: size.width,
        height: playableHeight) // 4
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
        //zombie.setScale(2) // tăng kích thước lên 2 lần, xem thêm hàm setscale của SKnode
        addChild(zombie)
            
        
        
        
        
        //Linh tinh
        let backgroundSize = background.size // Lấy size, width,height của 1 đối tượng
        let zombieSize = zombie.size
        print("backgroundSize: \(backgroundSize)")
        print("zombieSize: \(zombieSize)")
            debugDrawPlayableArea()
        
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        moveZombieToward(touchLocation)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let location = touch.locationInNode(self)
        
        sceneTouched(location) // co the goi truc tiep hàm moveZombieToward(touch) luon
    }
    
    }

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
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint) {
        sprite.zRotation = CGFloat(atan2(Double(direction.y), Double(direction.x)))
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

        //cách 1 : Cập nhật lại vị trí của zombie mỗi frame. cách cơ bản nhưng chuối
        //zombie.position = CGPoint(x: zombie.position.x + 4, y: zombie.position.y)
        
        
        //Cách 2 :
        //moveSprite(zombie,velocity: CGPoint(x: zombieMovePointsPerSec, y: 0))
        
        //cách 3 : di chuyển đến vị trí mình tap
        moveSprite(zombie, velocity: velocity)
        boundsCheckZombie()
        rotateSprite(zombie, direction: velocity)
        
        //print(velocity)
        }
    
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
            // 1
            let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
           //Velocity là ở Số điểm point mỗi giây, và bạn cần phải tìm ra bao nhiêu điểm để di chuyển zombie trong mỗi frame thời gian này. Để xác định số  điểm này rằng, ta nhân vận tốc của mỗi giây, với thời gian giữa mỗi 2 frame , ta sẽ có con số chính xác nếu thời gian giữa 2 frame là bao nhiêu thì di chuyển bấy nhiêu, bất chấp thời gian giữa 2 frame này ko đều nhau , cho mỗi frame thứ hai bởi các phần nhỏ của giây kể từ khi cập nhật cuối cùng. Bây giờ bạn có một điểm đại diện cho vị trí của zombie (mà bạn cũng có thể nghĩ đến như là một vector từ gốc đến vị trí của zombie) và một vector đại diện cho khoảng cách và hướng để di chuyển các zombie khung này:
            //print("Amount to move: \(amountToMove)")
            // 2
            
            sprite.position = CGPoint(
            x: sprite.position.x + amountToMove.x,
            y: sprite.position.y + amountToMove.y)
    }

    func moveZombieToward(location: CGPoint) {
                //offset : Độ lệch của x,y so với vị trí ban đầu
                let offset = CGPoint(x: location.x - zombie.position.x,
                y: location.y - zombie.position.y)
                //lenght : Độ dài từ vị trí củ đến vị trí mới, sẽ là cạnh huyền của 1 tam giác được tạo bởi điểm củ và điểm mới
                let length = sqrt(
                Double(offset.x * offset.x + offset.y * offset.y))
        
                // xác định hướng di chuyển mỗi giây, tăng x hay trừ x, tăng y hay trừ y
                let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        
                //print("offset.x:\(offset.x),offset.y:\(offset.y) ,direction.x:\(direction.x),direction.y:\(direction.y), lenght: \(length)")
        
        
                velocity = CGPoint(x: direction.x * zombieMovePointsPerSec, y: direction.y * zombieMovePointsPerSec)
                print("velocity.x:\(velocity.x),velocity.y:\(velocity.y)")
        
    }
    
    
    
    
    
     
}

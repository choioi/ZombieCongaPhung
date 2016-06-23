//
//  GameScene.swift
//  ZombieCongaPhung
//
//  Created by phung on 6/22/16.
//  Copyright (c) 2016 phung. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    
    
    let zombie1 = SKSpriteNode(imageNamed: "zombie1")
    var playableRect = CGRect()
    //2 tham số để tính thời gian chạy 2 hàm update()
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    //2 Tham số để khai báo khoảng cách đi được trong 1 khoảng thời gian của zombie1
    let zombieMovePointsPerSec:CGFloat = 240.0 // khai báo vận tốc mỗi giây
    var velocity = CGPointZero
    
       
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()//thiết lập nền trắng
        
        let background = SKSpriteNode(imageNamed: "background1") //node hình làm background
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)// mặc định về ở tâm
        background.zRotation = 0*CGFloat(M_PI)/180 //xoay 0 độ
        background.zPosition = -1 //background nên set -1 để khỏi che các node mặc định là 0
        addChild(background)
        
        
        //zombie1.SKSpriteNode(imageNamed: "zombie1")
        
        zombie1.position = CGPoint(x: 400, y: 400)
        zombie1.anchorPoint = CGPoint(x: 0.5, y: 0.5)// mặc định về ở tâm
        zombie1.zRotation = 0*CGFloat(M_PI)/180 //xoay 0 độ
        zombie1.zPosition = 0 //background nên set -1 để khỏi che các node mặc định là 0
        //zombie1.setScale(2) // tăng kích thước lên 2 lần, xem thêm hàm setscale của SKnode
        addChild(zombie1)
        
        
        
        //Linh tinh
        let backgroundSize = background.size // Lấy size, width,height của 1 đối tượng
        let zombie1Size = zombie1.size
        print("backgroundSize: \(backgroundSize)")
        print("zombie1Size: \(zombie1Size)")
        
    }
    func sceneTouched(touchLocation:CGPoint) {
        moveZombieToward(touchLocation)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let location = touch.locationInNode(self)
        
        sceneTouched(location)
    }
    
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPointZero
        let topRight = CGPoint(x: size.width, y: size.height)
        if zombie1.position.x <= bottomLeft.x {
        zombie1.position.x = bottomLeft.x
        velocity.x = -velocity.x
        }
        if zombie1.position.x >= topRight.x {
        zombie1.position.x = topRight.x
        velocity.x = -velocity.x }
        if zombie1.position.y <= bottomLeft.y {
            zombie1.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie1.position.y >= topRight.y {
        zombie1.position.y = topRight.y
        velocity.y = -velocity.y }
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
        print("\(dt*1000) milliseconds since last update")

        //cách 1 : Cập nhật lại vị trí của zombie1 mỗi frame. cách cơ bản nhưng chuối
        //zombie1.position = CGPoint(x: zombie1.position.x + 4, y: zombie1.position.y)
        
        
        //Cách 2 :
        //moveSprite(zombie1,velocity: CGPoint(x: zombieMovePointsPerSec, y: 0))
        
        //cách 3 : di chuyển đến vị trí mình tap
        moveSprite(zombie1, velocity: velocity)
            boundsCheckZombie()
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
                let offset = CGPoint(x: location.x - zombie1.position.x,
                y: location.y - zombie1.position.y)
                //lenght : Độ dài từ vị trí củ đến vị trí mới
                let length = sqrt(
                Double(offset.x * offset.x + offset.y * offset.y))
                
                let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
                velocity = CGPoint(x: direction.x * zombieMovePointsPerSec, y: direction.y * zombieMovePointsPerSec)
                
                
    }
    
    
    
    
    
     
}

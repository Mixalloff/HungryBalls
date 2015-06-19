/**
 * Created by mikhail on 17.06.15.
 */
package classes {
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.globalization.NumberParseResult;
import flash.text.TextField;

// Класс шара
public class Ball extends Sprite {
    private var scene: Playfield;
    public var radius: Number;
    private var color: uint;
    private var isPlayer: Boolean;

    private var speed: Number;
    private var angle: Number;
    private var acceleration: Number;

   // public var textField:TextField = new TextField();

    public function get centerX(): Number{
        return this.x + this.radius;
       // return this.sh.x + this.radius;
    }

    public function set centerX(posX: Number): void{
        this.x = posX - this.radius;
       // this.sh.x  = posX - this.radius;
    }

    public function get centerY(): Number{
        return this.y + this.radius;
       // return this.sh.y + this.radius;
    }

    public function set centerY(posY: Number): void{
        this.y = posY - this.radius ;
  //      this.sh.y  = posY - this.radius;
    }

    public function Ball(scene:Playfield, isPlayer: Boolean = false, radius:Number = 0, posX:Number = 0, posY:Number = 0, color:uint = 0xff0000) {
        this.scene = scene;
        this.isPlayer = isPlayer;
        if (isPlayer == false) {
            this.radius = Math.random() * 20 + 5; // [5; 25]
            DefinePosition();

            // Цвет из интервала
            var lowLimit: uint = 0xFFFF00;
            var highLimit: uint = 0xFFFFFF;
            this.color = lowLimit + Math.random() * (highLimit - lowLimit);
            // Формула цвета
            //color=r*256*256+g*256+b
        }
        else {
            this.radius = radius;

            /*var globPoint: Point = scene.globalToLocal(new Point(posX, posY));
            this.x = globPoint.x;
            this.y = globPoint.y;*/
            this.centerX = posX;
            this.centerY = posY;
            this.color = color;

        }

        this.angle = 0;
        this.speed = 0;
        this.acceleration = 0;

        // Координаты шара
       // textField.text = this.x+"; "+this.y+"; "+this.radius;
       // addChild(textField);

        Draw2d();


        //scene.balls[scene.balls.length] = this;
        scene.addBall(this);
    }

    public function enterFrame(event:Event):void {
        this.speed *= this.acceleration;
        this.acceleration *= 0.98;
        var speedX: Number = speed * Math.cos(this.angle);
        var speedY: Number = speed * Math.sin(this.angle);

        if (this.InField(this.centerX + speedX, this.centerY + speedY)){
            this.centerX += speedX;
            this.centerY += speedY;

            if (isPlayer) {
                trace("SpeedX = " + speedX, "SpeedY = " + speedY);
                trace("centerX = " + centerX, "centerY = " + centerY);
            }
        }
        else
        {
            if (this.centerX - this.radius + speedX < 0 || this.centerX + speedX + this.radius > this.scene.SizeX)
            {
                this.angle = Math.PI - this.angle;
            }
            else
            {
                this.angle = Math.PI + (Math.PI - this.angle);
            }
        }

        //textField.text = this.x+"; "+this.y;
        this.graphics.beginFill(0x00ff00);
        this.graphics.drawCircle(this.centerX, this.centerY, 1);
        this.graphics.endFill();

       //scene.CheckIntersect();
    }


    // Рисование двумерного шара
    private function Draw2d():void {
        this.graphics.beginFill(this.color);
        this.graphics.drawCircle(this.centerX, this.centerY, this.radius);
        this.graphics.endFill();

        var sh: Shape = new Shape();
        sh.graphics.beginFill(this.color, .2);
        sh.graphics.drawCircle(this.centerX, this.centerY, this.radius);
        sh.graphics.endFill();

        //this.graphics.beginFill(0x000000);
        //this.graphics.drawCircle(this.x, this.y, 1);
        //this.graphics.endFill();

        scene.addChild(sh);
        scene.addChild(this);
    }

    // Определяет позицию нового шара
    private function DefinePosition():void {
        var flag:Boolean = false;
        while (!flag) {
            flag = true;
            this.centerX = Math.random() * (scene.SizeX / 2 - this.radius) + this.radius;
            this.centerY = Math.random() * (scene.SizeY / 2 - this.radius) + this.radius;

           /* var globPoint: Point = scene.globalToLocal(new Point(this.x, this.y));
            this.x = globPoint.x;
            this.y = globPoint.y;*/

            if (this.InField(this.centerX, this.centerY)) {
                for (var i:int = 0; i < scene.balls.length; i++) {
                    if(scene.IsIntersects(this, scene.balls[i]))
                    {
                        flag = false;
                    }
                }
            }
        }
    }

    // Проверяет, находится ли шар в пределах поля
    private function InField(posX: Number, posY: Number): Boolean {
        if (posX + this.radius > this.scene.SizeX ||
                posX - this.radius < 0 ||
                posY + this.radius > this.scene.SizeY ||
                posY - this.radius < 0)
        {
            return false;
        }
        return true;
    }

    // Перемещение шара на заданное расстояние по 2 осям, если это возможно.
    // Если перемещение выходит за рамки поля, возвращает False
    private function Move(deltaX: Number, deltaY: Number): Boolean{
        if (!this.InField(this.centerX + deltaX, this.centerX + deltaY))
        {
            return false;
        }
        else
        {
            this.centerX += deltaX;
            this.centerY += deltaY;
            //trace(this.x, this.y);
            // textField.text = this.x + "; " + this.y;

        }
        return true;
    }

    // Случайное передвижение
    public function tryMove(event:MouseEvent): void{
        while (!Move(Math.random()*50 - 25, Math.random()*50 - 25))
        {
            continue;
        }
    }

    public function MoveByClick(event:MouseEvent): void{
     //   var clickPoint:Point = new Point(event.stageX, event.stageY);
    //    var scenePoint:Point = scene.globalToLocal(clickPoint);
     //   var clickX: Number = scenePoint.x - this.radius;
     //   var clickY: Number = scenePoint.y - this.radius;

        var clickX: Number = event.stageX - this.radius;
        var clickY: Number = event.stageY - this.radius;

        this.angle = Math.atan2(this.centerY - clickY, this.centerX - clickX);

     //   trace(this.angle + "; " + this.angle * 180 / Math.PI);

        this.speed = 15;
        this.acceleration = 1;
     //   trace(this.x, this.y, "Center: "+this.centerX, this.centerY);
    }

   /* public function set posX(x: Number): void {
        this.x = x - this.radius;
    }

    public function set posY(y: Number): void {
        this.y = y - this.radius;
    }*/
}
}

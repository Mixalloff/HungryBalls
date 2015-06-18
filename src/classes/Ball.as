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
import flash.text.TextField;

// Класс шара
public class Ball extends Sprite {
    private var scene: Playfield;
    private var radius: Number;
    private var color: uint;
    private var isPlayer: Boolean;

    private var speed: Number;
    private var angle: Number;
    private var acceleration: Number;

    //public var textField:TextField = new TextField();

    public function Ball(scene:Playfield, isPlayer: Boolean = false, radius:Number = 0, posX:Number = 0, posY:Number = 0, color:uint = 0xff0000) {
        this.scene = scene;
        this.isPlayer = isPlayer;
        if (isPlayer == false) {
            this.radius = Math.random() * 20 + 5; // [5; 25]
            DefinePosition();
            this.color = color;
        }
        else {
            this.radius = radius;
            this.x = posX;
            this.y = posY;
            this.color = color;
        }

        this.angle = 0;
        this.speed = 0;
        this.acceleration = 0;

        // Координаты шара
       // textField.text = this.x+"; "+this.y+"; "+this.radius;
       // addChild(textField);

        Draw2d();
        this.addEventListener(Event.ENTER_FRAME, enterFrame);

        //scene.balls[scene.balls.length] = this;
        scene.addBall(this);
    }

    function enterFrame(event:Event):void {
        this.speed *= this.acceleration;
        this.acceleration *= 0.995;
        var speedX: Number = speed * Math.cos(this.angle);
        var speedY: Number = speed * Math.sin(this.angle);

        if (this.InField(this.x + speedX, this.y + speedY)){
            this.x += speedX;
            this.y += speedY;
        }
        else
        {
            if (this.x + speedX < 0 || this.x + speedX + 2 * this.radius > this.scene.SizeX)
            {
                this.angle = Math.PI - this.angle;
            }
            else
            {
                this.angle = Math.PI + (Math.PI - this.angle);
            }
        }

    }

    function LineKoef(effectX: Number, effectY: Number):Number {
        return (this.y - effectY) / (this.x - effectX);
    }

    // Рисование двумерного шара
    private function Draw2d():void {
        this.graphics.beginFill(this.color);
        this.graphics.drawCircle(this.x, this.y, this.radius);
        this.graphics.endFill();
        scene.addChild(this);
    }

    // Определяет позицию нового шара
    private function DefinePosition():void {
        var flag:Boolean = true;
        while (flag == true) {
            flag = true;
            var posX:Number = Math.random() * (scene.SizeX - 2 * this.radius) + this.radius;
            var posY:Number = Math.random() * (scene.SizeY - 2 * this.radius) + this.radius;
            if (this.InField(posX, posY)) {
                for (var i:int = 0; i < scene.balls.length; i++) {
                    if (Math.sqrt(Math.pow((scene.balls[i].x - posX), 2) + Math.pow((scene.balls[i].y - posY), 2)) > scene.balls[i].radius + this.radius) {
                        flag = false;
                    }
                }
            }
            if (flag == false){
                var stagePoint:Point = new Point(posX, posY);
                var scenePoint:Point = scene.localToGlobal(stagePoint);
                this.x = scenePoint.x - this.radius;
                this.y = scenePoint.y - this.radius;

                //this.x = posX;
                //this.y = posY;
            }
        }
    }

    // Проверяет, находится ли шар в пределах поля
    private function InField(posX: Number, posY: Number): Boolean {
        if (posX + 2 * this.radius > this.scene.SizeX ||
                posX < 0 ||
                posY + 2 * this.radius > this.scene.SizeY ||
                posY < 0)
        {
            return false;
        }
        return true;
    }

    // Перемещение шара на заданное расстояние по 2 осям, если это возможно.
    // Если перемещение выходит за рамки поля, возвращает False
    private function Move(deltaX: Number, deltaY: Number): Boolean{
        if (!this.InField(this.x + deltaX, this.y + deltaY))
        {
            return false;
        }
        else
        {
            this.x += deltaX;
            this.y += deltaY;
            //trace(this.x, this.y);
            // textField.text = this.x + "; " + this.y;

        }
        return true;
    }

    public function tryMove(event:MouseEvent): void{
        while (!Move(Math.random()*50 - 25, Math.random()*50 - 25))
        {
            continue;
        }
    }

    public function MoveByClick(event:MouseEvent): void{
        var clickPoint:Point = new Point(event.stageX, event.stageY);
        var scenePoint:Point = scene.globalToLocal(clickPoint);
        var clickX: Number = scenePoint.x - this.radius;
        var clickY: Number = scenePoint.y - this.radius;

        this.angle = Math.atan2(this.y - clickY, this.x - clickX);

        trace(this.angle + "; " + this.angle * 180 / Math.PI);

        this.speed = 15;
        this.acceleration = 1;
    }

   /* public function set posX(x: Number): void {
        this.x = x - this.radius;
    }

    public function set posY(y: Number): void {
        this.y = y - this.radius;
    }*/
}
}

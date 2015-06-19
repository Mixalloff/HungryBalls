/**
 * Created by mikhail on 17.06.15.
 */
package classes {
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.text.TextField;

// Класс игрового поля
public class Playfield extends Sprite {
    private var xSize: Number;
    private var ySize: Number;
    private var color: uint;
    public var workPlace: Stage;
    public var balls: Array = new Array();

    public function Playfield(workPlace:Stage, width: Number = 500, height: Number = 400, color: uint = 0x550055) {
        this.workPlace = workPlace;
        this.xSize = width;
        this.ySize = height;
        this.x = 0;//(this.workPlace.stage.stageWidth - this.xSize) / 2;
        this.y = 0;//(this.workPlace.stage.fullScreenHeight - this.ySize) / 2;
        this.color = color;

        this.addEventListener(Event.ENTER_FRAME, enterFrame);

        Draw2d();

       /* var test: Shape = new Shape();
        test.graphics.beginFill(0x00ff00);
        test.graphics.drawRect(xSize, ySize, 20,20);
        test.graphics.endFill();
        this.addChild(test);*/
        DrawGrid();
    }

    // Сетка на поле
    function DrawGrid(): void {

        // Шаг
        var step: int = 50;
        for(var i: int = 0; i <= this.SizeX / step; i++ ) {
            var shape: Shape = new Shape();
            shape.graphics.lineStyle(1, 0x000000);
            shape.graphics.moveTo(i*step, 0);
            shape.graphics.lineTo(i*step, this.SizeY);
            this.addChild(shape);
        }
        for(var i: int = 0; i <= this.SizeY / step; i++ ) {
            var shape: Shape = new Shape();
            shape.graphics.lineStyle(1, 0x000000);
            shape.graphics.moveTo(0, i*step);
            shape.graphics.lineTo(this.SizeX, i*step);
            this.addChild(shape);
        }
    }

    function enterFrame(event:Event):void {
        this.CheckIntersect();

        if (balls[0] != null) {
            var square:Shape = new Shape();
            square.graphics.beginFill(0x000000);
            square.graphics.drawCircle(balls[0].centerX, balls[0].centerY, 1);
            square.graphics.endFill();
            this.addChild(square);
        }
    }

    public function addBall(ball: Ball): void {
        this.balls[this.balls.length] = ball;
    }

    // Рисование двумерного поля
    private function Draw2d(): void {
        //var square:Shape = new Shape();
        this.graphics.beginFill(this.color, 0.3);
        this.graphics.drawRect(0, 0, this.xSize, this.ySize);
        this.graphics.endFill();
        this.workPlace.addChild(this);
    }

    // Проверяет, пересекаются ли 2 шара (true - да, false - нет)
    public function IsIntersects(ball1: Ball, ball2: Ball): Boolean
    {
        // var ball1Point: Point = scene.globalToLocal(new Point(ball1.x, ball1.y));
        // var ball2Point: Point = scene.globalToLocal(new Point(ball2.x, ball2.y));

        return (Math.sqrt(Math.pow((ball1.centerX - ball2.centerX), 2) + Math.pow((ball1.centerY - ball2.centerY), 2)) < ball1.radius + ball2.radius);
    }

    // Проверка на пересечение шаров и удаление меньших при пересечении
    private function CheckIntersect(): void
    {
        for (var i:int = 0; i < this.balls.length - 1; i++) {
            for (var j:int = i + 1; j < this.balls.length; j++) {
                if (this.IsIntersects(this.balls[i], this.balls[j]))
                {
                    // Удаление меньшего шара
                    if(this.balls[i].radius < this.balls[j].radius) {
                        this.DeleteBall(this.balls[i], this.balls[j], i--);
                        break;
                    }
                    else{
                        this.DeleteBall(this.balls[j], this.balls[i], j--);
                    }
                }
            }
        }
    }

    // Удаление шара
    private function DeleteBall(smallBall: Ball, bigBall: Ball, ind: int): void
    {
        bigBall.Increase(smallBall.radius);
        this.removeChild(smallBall);
        this.balls.splice(ind, 1);
    }



    public function get SizeX(): Number{
        return xSize;
    }

    public function get SizeY(): Number{
        return ySize;
    }

}
}

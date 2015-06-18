/**
 * Created by mikhail on 17.06.15.
 */
package classes {
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.text.TextField;

// Класс игрового поля
public class Playfield extends Sprite {
    private var xSize: Number;
    private var ySize: Number;
    private var color: uint;
    public var workPlace: Sprite;
    public var balls: Array = new Array();

    public function Playfield(workPlace:Sprite, width: Number = 500, height: Number = 400, color: uint = 0x9400D3) {
        this.workPlace = workPlace;
        this.xSize = width;
        this.ySize = height;
        this.x = 0;//(this.workPlace.stage.stageWidth - this.xSize) / 2;
        this.y = 0;//(this.workPlace.stage.fullScreenHeight - this.ySize) / 2;
        this.color = color;

        Draw2d();
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

    public function get SizeX(): Number{
        return xSize;
    }

    public function get SizeY(): Number{
        return ySize;
    }

}
}

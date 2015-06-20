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
import flash.text.TextFormat;
import flash.text.engine.TextBlock;

// Класс игрового поля
public class Playfield extends Sprite {
    private var xSize: Number;
    private var ySize: Number;
    private var color: uint;
    public var workPlace: Stage;
    public var balls: Array = new Array();
    public var gameIsOver: Boolean = false;

    // Общая площадь всех шаров
    public var totalArea: Number;

    // Цвета из конфига
    public var userBallColor: uint;
    public var enemyBallColor1: uint;
    public var enemyBallColor2: uint;

    // Рисование двумерного поля
    private function Draw2d(): void {
        //var square:Shape = new Shape();
        this.graphics.beginFill(this.color, 0.3);
        this.graphics.drawRect(0, 0, this.xSize, this.ySize);
        this.graphics.endFill();
        this.workPlace.addChild(this);
    }

    // Удаление шара
    private function DeleteBall(smallBall: Ball, bigBall: Ball, ind: int): void
    {
        bigBall.Increase(smallBall.radius);
        this.removeChild(smallBall);
        this.balls.splice(ind, 1);
        if (smallBall.isPlayer) {
            this.GameOver(false);
        }
    }

    // Проверка на пересечение шаров и удаление меньших при пересечении
    private function CheckIntersect(): void
    {
        var minRadius: Number = balls[0];
        for (var i:int = 0; i < this.balls.length - 1; i++) {
            // Нахождение минимального радиуса
            if(balls[i].radius < minRadius)
            {
                minRadius = balls[i].radius;
            }
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

                    for (var k:int = 0; k < this.balls.length; k++) {
                        GenerateEnemyColorRGB(balls[k]);
                    }
                }
            }
        }

        if(balls[0] == minRadius)
        {
            this.GameOver(false);
        }
    }

    // Установка цвета шара пользователя
    public function set setUserBallColor(col: uint): void{
        this.balls[0].color = col;
        this.userBallColor = col;
    }

    public function Playfield(workPlace:Stage, width: Number = 500, height: Number = 400, color: uint = 0x550055) {
        this.workPlace = workPlace;
        this.xSize = width;
        this.ySize = height;
        this.x = 0;
        this.y = 0;
        this.color = color;
        this.totalArea = 0;
        this.addEventListener(Event.ENTER_FRAME, enterFrame);
        Draw2d();
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

    // Обработка смены кадра для поля
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

    // Добавление шара в массив
    public function addBall(ball: Ball): void {
        this.balls[this.balls.length] = ball;
        totalArea += Math.PI * Math.pow(ball.radius, 2);
        if (ball.isPlayer)
        {
            ball.color = userBallColor;
        }
    }

    // Получение объекта с компонентами цвета (r, g, b)
    function HexToRGB(value:uint):Object {
        var rgb:Object = new Object();
        rgb.r = (value >> 16) & 0xFF;
        rgb.g = (value >> 8) & 0xFF;
        rgb.b = value & 0xFF;
        return rgb;
    }

    // Генерация цвета из заданного интервала с учетом размеров
    public function GenerateEnemyColorRGB(ball: Ball): void{
        if (!ball.isPlayer) {
            var enemyLowLimitColor:Object = HexToRGB(this.enemyBallColor1);
            var enemyHighLimitColor:Object = HexToRGB(this.enemyBallColor2);

            // Средняя граница (для сравнения с шаром пользователя)
            var avgColor:Object = new Object();
            avgColor.r = Math.round((enemyHighLimitColor.r - enemyLowLimitColor.r) / 2);
            avgColor.g = Math.round((enemyHighLimitColor.g - enemyLowLimitColor.g) / 2);
            avgColor.b = Math.round((enemyHighLimitColor.b - enemyLowLimitColor.b) / 2);

            var lowRadiusLimit:Number = ball.radius;
            var highRadiusLimit:Number = ball.radius;

            // Находим максимальный и минимальный радиус
            for (var i:int = 1; i < this.balls.length; i++) {
                if (this.balls[i].radius < lowRadiusLimit) {
                    lowRadiusLimit = balls[i].radius;
                }
                if (this.balls[i].radius > highRadiusLimit) {
                    highRadiusLimit = balls[i].radius;
                }
            }

            // Цвет начала диапазона
            var startColorRange: Object = new Object();

            // Новый цвет
            var newCol:Object = new Object();

            if (ball.radius < this.balls[0].radius) {
                highRadiusLimit = this.balls[0].radius;
                startColorRange = enemyLowLimitColor;
            }
            else {
                lowRadiusLimit = this.balls[0].radius;
                startColorRange.r = enemyHighLimitColor.r - avgColor.r;
                startColorRange.g = enemyHighLimitColor.g - avgColor.g;
                startColorRange.b = enemyHighLimitColor.b - avgColor.b;
            }
            var proportion:Number = RadiusProportion(ball.radius, lowRadiusLimit, highRadiusLimit);
            newCol.r = startColorRange.r + Math.round(proportion * (avgColor.r));
            newCol.g = startColorRange.g + Math.round(proportion * (avgColor.g));
            newCol.b = startColorRange.b + Math.round(proportion * (avgColor.b));

            // Сгенерированный цвет шара
            ball.color = newCol.r * 256 * 256 + newCol.g * 256 + newCol.b;
        }
    }

    // Определение доли радиуса
    function RadiusProportion(radius: Number, smallRadius: Number, bigRadius: Number): Number{
        if (bigRadius != smallRadius){
            return ((radius - smallRadius) / (bigRadius - smallRadius));
        }
        return 1;
    }

    // Завершение игры
    public function GameOver(isPlayer: Boolean): void
    {
        var lbl: String;
        var gameOver: TextField = new TextField();
        var format: TextFormat = new TextFormat();
        format.size = 22;

        if (isPlayer)
        {
            lbl = "You win!";
        }
        else
        {
            lbl = "You lose!";
        }

        gameOver.text = "Game over! " + lbl;
        this.addChild(gameOver);
        gameOver.y -= 50;
        gameOver.width = 500;
        gameOver.setTextFormat(format);
        this.gameIsOver = true;
    }

    // Проверяет, пересекаются ли 2 шара (true - да, false - нет)
    public function IsIntersects(ball1: Ball, ball2: Ball): Boolean
    {
        return (Math.sqrt(Math.pow((ball1.centerX - ball2.centerX), 2) + Math.pow((ball1.centerY - ball2.centerY), 2)) < ball1.radius + ball2.radius);
    }

    // Получение ширины поля
    public function get SizeX(): Number{
        return xSize;
    }

    // Получение высоты поля
    public function get SizeY(): Number{
        return ySize;
    }

}
}

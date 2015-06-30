/**
 * Created by mikhail on 17.06.15.
 */
package classes {
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.media.Sound;
import flash.net.URLRequest;
import flash.utils.Timer;
import flash.utils.getTimer;

// Класс игрового поля
public class Playfield extends Sprite {
    private var xSize: Number;
    private var ySize: Number;
    private var color: uint;
    private var minimalRadius: Number;
    public var workPlace: Main;
    public var balls: Array = new Array();
    public var gameIsOver: Boolean = false;

    // Общая площадь всех шаров
    public var totalArea: Number;

    // Цвета из конфига
    public var userBallColor: uint;
    public var enemyBallColor1: uint;
    public var enemyBallColor2: uint;

    // Шар пользователя
    public var userBall: Ball;

    var timer:Timer;

    // Количество тиков в секунду
    const TICKS_PER_SECOND:int = 25;
    const TICK_DELAY: Number = 1000 / TICKS_PER_SECOND;
    const MAX_DELAY: int = 5;

    private var next_game_tick: int = getTimer();

    // Звуки
    public var increaseSnd:Sound = new Sound(new URLRequest(Main.ResourcesPath + "/Sounds/bubble.mp3"));
    public var winSnd:Sound = new Sound(new URLRequest(Main.ResourcesPath + "/Sounds/win.mp3"));
    public var loseSnd:Sound = new Sound(new URLRequest(Main.ResourcesPath + "/Sounds/lose.mp3"));

    public function Playfield(workPlace: Main, width: Number = 500, height: Number = 400, color: uint = 0xAFEEEE) {
        this.workPlace = workPlace;
        this.xSize = width;
        this.ySize = height;
        this.x = 0;
        this.y = 0;
        this.color = color;
        this.totalArea = 0;

        var userBallRadius: Number = 15;
        var userBallX: Number = 20;
        var userBallY: Number = 20;
        userBall = new Ball(this, true, userBallRadius, userBallX, userBallY);

        // Подписка на события
        workPlace.stage.scaleMode = StageScaleMode.NO_SCALE;
        workPlace.stage.addEventListener(MouseEvent.CLICK, userBall.CalculateAngle);
        workPlace.stage.addEventListener(MouseEvent.MOUSE_DOWN, userBall.StartMouseDown);
        workPlace.stage.addEventListener(MouseEvent.MOUSE_UP, userBall.EndMouseDown);
        Draw2d();
        //DrawGrid();

    }

    // Устанавливает значения из конфига
    public function SetConfigData(data:Object): void {
        this.setUserBallColor = data.user.color.r * 256 * 256 + data.user.color.g * 256 + data.user.color.b;
        this.enemyBallColor1 = data.enemy.color1.r * 256 * 256 + data.enemy.color1.g * 256 + data.enemy.color1.b;
        this.enemyBallColor2 = data.enemy.color2.r * 256 * 256 + data.enemy.color2.g * 256 + data.enemy.color2.b;
        var startEnemyCount: Number = data.enemyCount;
        for(var i: int = 0; i < startEnemyCount; i++ ) {
            new Ball(this, false);
        }
        for (var k:int = 1; k < this.balls.length; k++) {
            this.GenerateEnemyColorRGB(this.balls[k]);
        }

        Start();
    }

    public function Start(): void {
        // Подписка на событие таймера
        timer = new Timer(1);
        timer.addEventListener(TimerEvent.TIMER, this.newTick);
        timer.start();
    }

    public const fieldThickness: Number = 5;

    // Рисование двумерного поля
    private function Draw2d(): void {
        /*var colors:Array = [0x004400, 0x000088];
        var alphas:Array = [1, 1];
        var ratios:Array = [0, 255];
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(this.xSize, this.ySize, Math.PI / 2, 0, 50);
        this.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);*/

        this.graphics.beginFill(this.color);
        this.graphics.lineStyle(fieldThickness, 0);
        this.graphics.drawRect(0, 0, this.xSize, this.ySize);
        this.graphics.endFill();
        this.workPlace.addChild(this);
    }

    // Удаление шара
    private function DeleteBall(smallBall: Ball, bigBall: Ball, ind: int): void
    {
        bigBall.Increase(smallBall);
        this.removeChild(smallBall);
        this.balls.splice(ind, 1);
        CheckEndGame(smallBall, bigBall);
    }

    function CheckEndGame(smallBall: Ball, bigBall: Ball): void {
        // Проверка окончания
        if (smallBall.isPlayer) {
            this.GameOver("Вы проиграли! Вас уничтожили!", false);
        }
        else {
            if (Math.PI * Math.pow(bigBall.radius, 2) > 0.5 * this.totalArea) {
                if (bigBall.isPlayer == true) {
                    this.GameOver("Вы победили! Ваша площадь больше суммы других!", true);
                }
                else {
                    this.GameOver("Вы проиграли! Площадь одного из соперников больше суммы остальных!", false);
                }
            }
        }
    }

    // Получение минимального радиуса
    private function GetMinRadius(): void {
        var minRad: Number = balls[0].radius;
        for (var i:int = 1; i < this.balls.length; i++) {
            if(balls[i].radius < minRad)
            {
                minRad = balls[i].radius;
            }
        }
        this.minimalRadius = minRad;
    }

    // Проверка на пересечение шаров и удаление меньших при пересечении
    private function CheckIntersect(): void
    {
        //var minRadius: Number = balls[0].radius;
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

                    for (var k:int = 0; k < this.balls.length; k++) {
                        GenerateEnemyColorRGB(balls[k]);
                    }
                    GetMinRadius();
                }
            }
        }

        if(balls[0].radius == this.minimalRadius && balls[0].isPlayer)
        {
            this.GameOver("Вы проиграли! Ваш радиус наименьший!", false);
        }
    }

    // Установка цвета шара пользователя
    public function set setUserBallColor(col: uint): void{
        this.balls[0].color = col;
        this.userBallColor = col;
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

    // Обработка тика для поля
    public function newTick(e: TimerEvent):void {
            // Текущее количество прошедших циклов
            var loops: int = 0;

            // Сглаживание разницы реальной позиции и отрисованного элемента
            var interpolation: Number;

            while (getTimer() > next_game_tick && loops < MAX_DELAY) {
                // Изменение координат установленное количество раз в секунду
                for (var i:int = 0; i < balls.length; i++) {
                    balls[i].CalculateCoordinates();
                }
                next_game_tick += TICK_DELAY;
                loops++;
                this.CheckIntersect();
            }
            interpolation = (getTimer() + TICK_DELAY - next_game_tick) / TICK_DELAY;
            // Отрисовка в соответствии с текущим FPS
            for (var j:int = 0; j < balls.length; j++) {
                balls[j].Move(interpolation);
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
        GetMinRadius();
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
    public function GameOver(alertMessage: String, isWin: Boolean): void
    {
        if(isWin){
            winSnd.play();
        }
        else{
            loseSnd.play();
        }

        for (var k:int = 0; k < this.balls.length; k++) {
            GenerateEnemyColorRGB(balls[k]);
        }
        this.gameIsOver = true;
        workPlace.ShowEndGameWindow(alertMessage);
        timer.stop();

        // Отписка от событий
        stage.removeEventListener(MouseEvent.CLICK, userBall.CalculateAngle);
        stage.removeEventListener(MouseEvent.MOUSE_DOWN, userBall.StartMouseDown);
        stage.removeEventListener(MouseEvent.MOUSE_UP, userBall.EndMouseDown);
        timer.removeEventListener(TimerEvent.TIMER, this.newTick);
    }

    // Очистка поля
    public function ClearField(): void {
        if (this.numChildren > 0){
            this.removeChildren(0, this.numChildren - 1);
        }
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

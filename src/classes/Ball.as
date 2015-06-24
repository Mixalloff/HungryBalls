/**
 * Created by mikhail on 17.06.15.
 */
package classes {
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.utils.getTimer;
import flash.utils.setInterval;

// Класс шара
public class Ball extends Sprite {
    private var scene: Playfield;
    private var startTime: Number;
    private var startDelay: Number;
    public var isPlayer: Boolean;
    public var radius: Number;

    // Физические характеристики
    const gravAcceleration: Number = 9.8;
    private var angle: Number = 0;
    private var frictionPower: Number = 0;
    private var koefFriction: Number = 0.02;
    private var weight: Number = 0;
    private var density: Number = 0.01; // плотность
    private var speed: Number = 0;
    private var power: Number = 0;
    private var colorBall: uint;

  // private var acceleration: Number;

    // Установка цвета шара
    public function set color(col: uint): void{
        var colorTransform:ColorTransform = new ColorTransform();
        colorTransform.color = col;
        this.transform.colorTransform = colorTransform;
        this.colorBall = col;
    }

    // Получение цвета шара
    public function get color(): uint{
        return this.colorBall;
    }

    // Получение X координаты шара
    public function get centerX(): Number{
        return this.x + this.radius;
    }

    // Установка X координаты шара
    public function set centerX(posX: Number): void{
        this.x = posX - this.radius;
    }

    // Получение Y координаты шара
    public function get centerY(): Number{
        return this.y + this.radius;
    }

    // Установка Y координаты шара
    public function set centerY(posY: Number): void{
        this.y = posY - this.radius;
    }

    // Конструктор
    public function Ball(scene:Playfield, isPlayer: Boolean = false, radius:Number = 0, posX:Number = 0, posY:Number = 0, color:uint = 0xff0000) {
        this.scene = scene;
        this.isPlayer = isPlayer;
        if (isPlayer == false) {
            this.radius = Math.random() * 15 + 5;
            DefinePosition();
           // setInterval(this.enemyBallTick, 1000 / scene.fps);
        }
        else {
            this.radius = radius;
            this.centerX = posX;
            this.centerY = posY;
            this.color = color;
            //setInterval(this.userBallTick, 1000 / scene.fps);
        }

        this.startTime = getTimer();
        this.startDelay = 3000;

        PhysicCalculate(0);
        Draw2d();
        scene.addBall(this);
    }

    // Вычисление физических показателей с учетом переданной силы
    private function PhysicCalculate(power: Number): void
    {
        this.weight = 4 / 3 * Math.PI * Math.pow(this.radius, 3) * this.density;
        this.frictionPower = this.koefFriction * this.weight * gravAcceleration;
        this.power = power - this.frictionPower;
        this.speed = this.power / this.weight;
    }

    // Обработка смены кадра для чужих шаров
    public function enemyBallTick():void {
        if (!scene.gameIsOver) {
            RandomMove();
        }
    }

    // Перемещение шара на заданное расстояние по 2 осям, если это возможно.
    // Если перемещение выходит за рамки поля, возвращает False
    private function Move(): void{
        if (this.power >= this.frictionPower) {
            this.power -= this.frictionPower;
        }
        else
        {
            this.power = 0;
        }
        this.speed = this.power / this.weight;
        var speedX: Number = speed * Math.cos(this.angle);
        var speedY: Number = speed * Math.sin(this.angle);
        while(speedX > 2 * this.radius || speedY > 2 * this.radius){
            this.PhysicCalculate(power * 0.9);
            speedX = speed * Math.cos(this.angle);
            speedY = speed * Math.sin(this.angle);
        }
        if (this.InField(this.centerX + speedX, this.centerY + speedY)){
            this.centerX += speedX;
            this.centerY += speedY;
        }
        else
        {
            //Затухание при косании со стенкой
            var damping: Number;

            // Минимальный коэффициент затухания
            var minDamping: Number = 0.8;

            if (this.centerX - this.radius + speedX < 0 || this.centerX + speedX + this.radius > this.scene.SizeX)
            {
                this.angle = Math.PI - this.angle;
                damping = Math.abs(Math.sin(this.angle)) * (1 - minDamping) + minDamping;
            }
            else
            {
                this.angle = Math.PI + (Math.PI - this.angle);
                damping = Math.abs(Math.cos(this.angle)) * (1 - minDamping) + minDamping;
            }
            this.PhysicCalculate(power * damping);
        }
    }

    // Обработка смены кадра для пользовательского шара
    public function userBallTick():void {
         this.Move();
    }

    // Рисование двумерного шара
    private function Draw2d():void {
        this.graphics.beginFill(this.color);
        this.graphics.drawCircle(this.radius, this.radius, this.radius);
        this.graphics.endFill();

        scene.addChild(this);
    }

    // Увеличение шара
    public function Increase(smallBall: Ball): void{
        this.radius = Math.sqrt(Math.pow(this.radius, 2) + Math.pow(smallBall.radius, 2));

        if (!this.InField(this.centerX, centerY))
        {
            if (centerX + this.radius > this.scene.SizeX){
                centerX -= centerX + this.radius - this.scene.SizeX;
            }
            if (centerX - this.radius < 0){
                centerX -= centerX - this.radius;
            }
            if (centerY + this.radius > this.scene.SizeY){
                centerY -= centerY + this.radius - this.scene.SizeY;
            }
            if (centerY - this.radius < 0){
                centerY -= centerY - this.radius;
            }
        }

        // Перерисовка
        this.graphics.clear();
        this.graphics.beginFill(this.color);
        this.graphics.drawCircle(this.radius, this.radius, this.radius);
        this.graphics.endFill();

        // Пересчет физики
        this.PhysicCalculate(this.power);
    }

    // Определяет позицию нового шара
    private function DefinePosition():void {
        var flag:Boolean = false;
        while (!flag) {
            flag = true;
            this.centerX = Math.random() * (scene.SizeX - 2 * this.radius) + this.radius;
            this.centerY = Math.random() * (scene.SizeY - 2 * this.radius) + this.radius;

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

    // Генерирует случайные параметры для передвижения
    public function RandomMove(): void{
        var PowerKoef: Number = 200;

        if (this.power == 0 && getTimer() - this.startTime > this.startDelay) {
            this.angle = (Math.random() * 360 + 180) / 180 * Math.PI;
            PhysicCalculate(Math.random() * PowerKoef * this.radius);
        }
        this.Move();
    }

    // Время начала нажатия мыши
    private var startMouseDownTime: int;

    // Обработка начала нажатия мыши
    public function StartMouseDown(event:MouseEvent): void {
        this.startMouseDownTime = getTimer();
    }

    // Обработка отпускания мыши
    public function EndMouseDown(event:MouseEvent): void {
        this.power = (getTimer() - this.startMouseDownTime);
        if(this.power > 1000)
        {
            this.power = 1000;
        }
        this.PhysicCalculate(power * this.radius);
    }

    // Обработка клика
    public function CalculateAngle(event:MouseEvent): void{
        var clickX: Number = event.stageX - this.radius;
        var clickY: Number = event.stageY - this.radius;
        this.angle = Math.atan2(this.centerY - clickY, this.centerX - clickX);
      //  this.acceleration = 1;
    }
}
}

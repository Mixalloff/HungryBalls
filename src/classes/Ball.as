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
    protected var scene: Playfield;
   // protected var startTime: Number;
    //protected var startDelay: Number;
   // public var isPlayer: Boolean;
    public var radius: Number;

    // Физические характеристики
    private const gravAcceleration: Number = 9.8;
    protected var angle: Number = 0;
    protected var frictionPower: Number = 0;
    protected var koefFriction: Number = 0.02;
    protected var weight: Number = 0;
    protected var density: Number = 0.01; // плотность
    protected var speed: Number = 0;
    protected var power: Number = 0;
    protected var colorBall: uint;

    //protected var targetX: Number;
    //protected var targetY: Number;

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

    // Более точные координаты шара, чем унаследованные X и Y
    private var accurateX: Number;
    private var accurateY: Number;

    // Получение X координаты шара
    public function get centerX(): Number{
        //return this.x + this.radius;
        return this.accurateX + this.radius;
    }

    // Установка X координаты шара
    public function set centerX(posX: Number): void{
        this.accurateX = posX - this.radius;
        this.x = this.accurateX;
    }

    // Получение Y координаты шара
    public function get centerY(): Number{
        //return this.y + this.radius;
        return this.accurateY + this.radius;
    }

    // Установка Y координаты шара
    public function set centerY(posY: Number): void{
        this.accurateY = posY - this.radius;
        this.y = this.accurateY;
    }

    // Конструктор
    public function Ball(scene:Playfield, radius:Number = 0, posX:Number = 0, posY:Number = 0, color:uint = 0xff0000) {
        this.scene = scene;

        this.radius = radius;
        this.centerX = posX;
        this.centerY = posY;
        this.color = color;

       // this.targetX = this.centerX;
       // this.targetY = this.centerY;

        PhysicCalculate(0);
        Draw2d();
       // scene.addBall(this);
    }

    // Вычисление физических показателей с учетом переданной силы
    protected function PhysicCalculate(power: Number): void
    {
        this.weight = 4 / 3 * Math.PI * Math.pow(this.radius, 3) * this.density;
        this.frictionPower = this.koefFriction * this.weight * gravAcceleration;
        this.power = power - this.frictionPower;
        this.speed = this.power / this.weight;
    }

    // Пересчет координат
    public function Move(diff: Number): void{
        if (this.power >= this.frictionPower) {
            this.power -= this.frictionPower;
        }
        else
        {
            this.power = 0;
        }
        this.speed = this.power / this.weight;
        var speedX: Number = speed * Math.cos(this.angle) * diff;
        var speedY: Number = speed * Math.sin(this.angle)* diff;
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

    // Перерисовка шара с заданным сглаживанием
    /*public function Move(): void{
        var speedX: Number = speed * Math.cos(this.angle);
        var speedY: Number = speed * Math.sin(this.angle);

        this.centerX = targetX + speedX;
        this.centerY = targetY + speedY;
    }*/

    // Рисование двумерного шара
    protected function Draw2d():void {
        this.graphics.beginFill(this.color);
        this.graphics.drawCircle(this.radius, this.radius, this.radius);
        this.graphics.endFill();

    //    scene.addChild(this);
    }

    // Увеличение шара
    public function Increase(smallBall: Ball): void{
        scene.workPlace.loader.sounds.increaseSnd.play(250);

        this.radius = Math.sqrt(Math.pow(this.radius, 2) + Math.pow(smallBall.radius, 2));

        if (!this.InField(this.centerX, centerY))
        {
            if (centerX + this.radius > this.scene.SizeX){
                centerX -= centerX + this.radius - (this.scene.SizeX - this.scene.x);
            }
            if (centerX - this.radius < 0){
                centerX -= centerX - this.radius;
            }
            if (centerY + this.radius > this.scene.SizeY){
                centerY -= centerY + this.radius - (this.scene.SizeY - this.scene.y);
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

    // Проверяет, находится ли шар в пределах поля
    protected function InField(posX: Number, posY: Number): Boolean {
        return !(posX + this.radius > this.scene.SizeX ||
                posX - this.radius < 0 ||
                posY + this.radius > this.scene.SizeY ||
                posY - this.radius < 0);
    }
}
}

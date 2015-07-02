/**
 * Created by mikhail on 02.07.15.
 */
package classes {
import flash.utils.getTimer;

public class EnemyBall extends Ball{
    protected var startTime: Number;
    protected var startDelay: Number;

    public function EnemyBall(scene:Playfield, radius:Number = 0, posX:Number = 0, posY:Number = 0, color:uint = 0xff0000) {
        radius = Math.random() * 15 + 5;
        super(scene, radius, posX, posY, color);
        DefinePosition();
        this.startTime = getTimer();
        this.startDelay = 3000;

        scene.addBall(this);
    }

    // Определяет позицию нового шара
    public function DefinePosition():void {
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
        this.targetX = this.centerX;
        this.targetY = this.centerY;
    }

    public function ChangeCoordinates(): void{
        RandomMove();
        CalculateCoordinates();
    }

    public function RandomMove(): void{
        var PowerKoef: Number = 200;

        if (this.power == 0 && getTimer() - this.startTime > this.startDelay) {
            this.angle = (Math.random() * 360 + 180) / 180 * Math.PI;
            PhysicCalculate(Math.random() * PowerKoef * this.radius);
        }
    }
}
}

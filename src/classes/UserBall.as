/**
 * Created by mikhail on 02.07.15.
 */
package classes {
import flash.events.MouseEvent;
import flash.utils.getTimer;

public class UserBall extends Ball{
    // Время начала нажатия мыши
    private var startMouseDownTime: int;

    public function UserBall(scene:Playfield, radius:Number = 0, posX:Number = 0, posY:Number = 0, color:uint = 0xff0000) {
        /*this.radius = radius;
        this.centerX = posX;
        this.centerY = posY;
        this.color = color;*/
        super(scene, radius, posX, posY, color);
        scene.addBall(this);
    }

    public function ChangeCoordinates(): void{
        CalculateCoordinates();
    }

    // Обработка начала нажатия мыши
    public function StartMouseDown(event:MouseEvent): void {
        this.startMouseDownTime = getTimer();
    }

    // Обработка отпускания мыши
    public function EndMouseDown(event:MouseEvent): void {
        CalculateAngle(event.stageX, event.stageY);

        this.power = (getTimer() - this.startMouseDownTime);
        if(this.power > 1000)
        {
            this.power = 1000;
        }
        this.PhysicCalculate(power * this.radius);
    }

    // Рассчет угла
    public function CalculateAngle(posx: Number, posy: Number): void{
        var clickX: Number = posx - this.radius;
        var clickY: Number = posy - this.radius;
        this.angle = Math.atan2(this.centerY - clickY, this.centerX - clickX);
    }

}
}

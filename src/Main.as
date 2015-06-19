package {

import classes.Ball;
import classes.Playfield;

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.MouseEvent;
import flash.text.TextField;

public class Main extends Sprite {
    public function Main() {

       /* var workPlace: Sprite = new Sprite();
        workPlace.graphics.beginFill(0xFFFFD3, 1);
        workPlace.graphics.drawRect(-200, 0, 1000, 1000);
        workPlace.graphics.endFill();
        this.addChild(workPlace);*/

        //stage.displayState = StageDisplayState.FULL_SCREEN;

        stage.color = 0x000000;
        stage.scaleMode = StageScaleMode.NO_SCALE;

        var newScene: Playfield = new Playfield(this);
        var newBall: Ball = new Ball(newScene, true, 20, 20, 20);

        var arr:Array = new Array();

        for(var i: int = 0; i < 20; i++ ) {
            arr[arr.length] = new Ball(newScene, false);
        }

       // workPlace.addEventListener(MouseEvent.CLICK, newBall.tryMove);
        stage.addEventListener(MouseEvent.CLICK, newBall.MoveByClick);
    }
}
}

package {

import classes.Ball;
import classes.Playfield;

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

public class Main extends Sprite {
    public function Main() {

       // stage.color = 0x000000;
        stage.scaleMode = StageScaleMode.NO_SCALE;

        var newScene: Playfield = new Playfield(stage);
        var newBall: Ball = new Ball(newScene, true, 20, 20, 20);

        for(var i: int = 0; i < 2; i++ ) {
            new Ball(newScene, false);
        }

       // workPlace.addEventListener(MouseEvent.CLICK, newBall.tryMove);
        stage.addEventListener(MouseEvent.CLICK, newBall.MoveByClick);
        newBall.addEventListener(Event.ENTER_FRAME, newBall.enterFrame);
    }
}
}

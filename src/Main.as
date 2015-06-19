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

       /* var workPlace: Sprite = new Sprite();
        workPlace.graphics.beginFill(0xFFFFD3, 1);
        workPlace.graphics.drawRect(-200, 0, 1000, 1000);
        workPlace.graphics.endFill();
        this.addChild(workPlace);*/

        //stage.displayState = StageDisplayState.FULL_SCREEN;

       // stage.color = 0x000000;
        stage.scaleMode = StageScaleMode.NO_SCALE;

        var newScene: Playfield = new Playfield(stage);
        var newBall: Ball = new Ball(newScene, true, 20, 50, 50);

     //   var arr:Array = new Array();

        for(var i: int = 0; i < 2; i++ ) {
            new Ball(newScene, false);
        }


        var step: int = 50;
        for(var i: int = 0; i <= newScene.SizeX / step; i++ ) {
            var shape: Shape = new Shape();
            shape.graphics.lineStyle(1, 0x000000);
            shape.graphics.moveTo(i*step, 0);
            shape.graphics.lineTo(i*step, newScene.SizeY);
            this.addChild(shape);
        }
        for(var i: int = 0; i <= newScene.SizeY / step; i++ ) {
            var shape: Shape = new Shape();
            shape.graphics.lineStyle(1, 0x000000);
            shape.graphics.moveTo(0, i*step);
            shape.graphics.lineTo(newScene.SizeX, i*step);
            this.addChild(shape);
        }


       /* var test: Shape = new Shape();
        test.graphics.beginFill(0x0000ff);
        test.graphics.drawRect(newScene.SizeX, newScene.SizeY, 20,20);
        test.graphics.endFill();
        this.addChild(test);*/


       // workPlace.addEventListener(MouseEvent.CLICK, newBall.tryMove);
        stage.addEventListener(MouseEvent.CLICK, newBall.MoveByClick);
        newBall.addEventListener(Event.ENTER_FRAME, newBall.enterFrame);
    }
}
}

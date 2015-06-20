package {

import classes.Ball;
import classes.Playfield;

import flash.display.Sprite;

import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.text.TextField;
import com.adobe.serialization.json.JSON;

public class Main extends Sprite {
    public var newScene: Playfield;
    public var userBall: Ball;
    public var startEnemyCount: Number;

    public function Main() {

        newScene = new Playfield(stage);
        userBall = new Ball(newScene, true, 10, 20, 20);
        // Загрузка конфига
        const CONFIG_URL:String = "gameConfig.json";
        getJson(CONFIG_URL);

       // stage.color = 0x000000;
        stage.scaleMode = StageScaleMode.NO_SCALE;

       // workPlace.addEventListener(MouseEvent.CLICK, newBall.tryMove);
        stage.addEventListener(MouseEvent.CLICK, userBall.CalculateAngle);
        userBall.addEventListener(Event.ENTER_FRAME, userBall.enterFrame);

        stage.addEventListener(MouseEvent.MOUSE_DOWN, userBall.StartMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_UP, userBall.EndMouseDown);

    }

    private function onLoaderComplete(e:Event):void{
        var loader:URLLoader = URLLoader(e.target);
        var data:Object = com.adobe.serialization.json.JSON.decode(loader.data);

        newScene.setUserBallColor = data.user.color.r * 256 * 256 + data.user.color.g * 256 + data.user.color.b;
        newScene.enemyBallColor1 = data.enemy.color1.r * 256 * 256 + data.enemy.color1.g * 256 + data.enemy.color1.b;
        newScene.enemyBallColor2 = data.enemy.color2.r * 256 * 256 + data.enemy.color2.g * 256 + data.enemy.color2.b;
        this.startEnemyCount = data.enemyCount;
        for(var i: int = 0; i < this.startEnemyCount; i++ ) {
            new Ball(newScene, false);
        }
        for (var k:int = 1; k < newScene.balls.length; k++) {
         //this.GenerateEnemyColor(balls[k]);
            newScene.GenerateEnemyColorRGB(newScene.balls[k]);
         }

    }

    function getJson(fileName: String): void{
        var urlRequest:URLRequest  = new URLRequest(fileName);
        var urlLoader:URLLoader = new URLLoader();
        urlLoader.addEventListener(Event.COMPLETE, onLoaderComplete);

        try{
            urlLoader.load(urlRequest);
        } catch (error:Error) {
            trace("Cannot load : " + error.message);
        }
    }
}
}

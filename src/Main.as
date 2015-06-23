package {

import classes.Ball;
import classes.Playfield;
import classes.PlayfieldEvent;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.text.TextField;
import com.adobe.serialization.json.JSON;
import flash.text.TextFormat;
import flashx.textLayout.formats.TextAlign;

public class Main extends Sprite {
    public var newScene: Playfield;
    public var userBall: Ball;
    public var startEnemyCount: Number;

    // Файл конфига
    const CONFIG_URL:String = "gameConfig.json";

    public function Main() {
        StartNewGame();
    }

    // Завершение игры
    public function FinishGame(e:PlayfieldEvent): void {
        trace("game is finished!");

        stage.removeEventListener(MouseEvent.CLICK, userBall.CalculateAngle);
        userBall.removeEventListener(Event.ENTER_FRAME, userBall.userBallEnterFrame);
        stage.removeEventListener(MouseEvent.MOUSE_DOWN, userBall.StartMouseDown);
        stage.removeEventListener(MouseEvent.MOUSE_UP, userBall.EndMouseDown);
        newScene.removeEventListener(PlayfieldEvent.GAME_FINISHED, this.FinishGame);

        ShowEndGameWindow(newScene.endGameMessage);
    }

    // Открытие окна окончания игры
    function ShowEndGameWindow(text: String): void {
        var win: Sprite = new Sprite();
        var infoText: TextField = new TextField();
        var winBtn: Sprite = new Sprite();
        var btnText: TextField = new TextField();

        // Параметры окна
        var winWidth: Number = 350;
        var winHeight: Number = 150;
        var winX: Number = newScene.x + (newScene.SizeX - winWidth) / 2;
        var winY: Number = newScene.y + (newScene.SizeY - winHeight) / 2;
        var winBackColor: uint = 0x000000;

        // Параметры текста
        var infoTextFormat: TextFormat = new TextFormat();
        infoTextFormat.size = 22;
        infoTextFormat.color = 0xffffff;
        infoTextFormat.leftMargin = 10;
        infoText.text = text;
        infoText.x = winX;
        infoText.y = winY;
        infoText.width = winWidth;
        infoText.setTextFormat(infoTextFormat);
        infoText.wordWrap = true;

        // Параметры кнопки
        var btnWidth: Number = 125;
        var btnHeight: Number = 40;
        var restartBtnColor: uint = 0x0000ff;
        var btnX: Number = winX + (winWidth - btnWidth) / 2;
        var btnY: Number = winY + (winHeight - btnHeight) - 5;

        // Параметры текста кнопки
        var btnTextFormat: TextFormat = new TextFormat();
        btnTextFormat.size = 22;//btnTextFormat.aut
        btnTextFormat.align = TextAlign.CENTER;
        btnTextFormat.color = 0xffffff;
        btnText.text = "Рестарт!";
        btnText.x = btnX;
        btnText.y = btnY;
        btnText.width = btnWidth;
        btnText.setTextFormat(btnTextFormat);

        win.graphics.beginFill(winBackColor);
        win.graphics.drawRect(winX, winY, winWidth, winHeight);
        win.graphics.endFill();

        winBtn.graphics.beginFill(restartBtnColor);
        winBtn.graphics.drawRect(btnX , btnY, btnWidth, btnHeight);
        winBtn.graphics.endFill();

        this.addChild(win);
        win.addChild(infoText);
        win.addChild(winBtn);
        win.addChild(btnText);

       // winBtn.addEventListener(MouseEvent.CLICK, RestartBtnClick);
        btnText.addEventListener(MouseEvent.CLICK, RestartBtnClick);
    }

    // Обработка нажатия кнопки "Рестарт"
    public function RestartBtnClick(event:MouseEvent): void {
        trace("Restart button clicked");
        this.StartNewGame();
    }

    // Начало новой игры
    public function StartNewGame(): void {
        if (this.numChildren > 0){
            newScene.ClearField();
            this.removeChildren(0, this.numChildren - 1);
        }
        trace("game is started!");

        var userBallRadius: Number = 15;
        var userBallX: Number = 20;
        var userBallY: Number = 20;

        newScene = new Playfield(this);
        userBall = new Ball(newScene, true, userBallRadius, userBallX, userBallY);

        // Загрузка конфига
        getJson(CONFIG_URL);

        // stage.color = 0x000000;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.addEventListener(MouseEvent.CLICK, userBall.CalculateAngle);
        userBall.addEventListener(Event.ENTER_FRAME, userBall.userBallEnterFrame);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, userBall.StartMouseDown);
        stage.addEventListener(MouseEvent.MOUSE_UP, userBall.EndMouseDown);
        newScene.addEventListener(PlayfieldEvent.GAME_FINISHED, this.FinishGame);
    }

    // Установка параметров из конфига при завершении его загрузки
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
            newScene.GenerateEnemyColorRGB(newScene.balls[k]);
         }

        this.dispatchEvent(new PlayfieldEvent(PlayfieldEvent.GAME_STARTED));
    }

    // Получение JSON из файла-конфига
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

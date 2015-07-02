package {

import classes.Playfield;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.text.TextField;
import com.adobe.serialization.json.JSON;
import flash.text.TextFormat;
import flashx.textLayout.formats.TextAlign;

public class Main extends Sprite {
    public var newScene: Playfield;

    public static const ResourcesPath: String = "../../../Resources";

    // Файл конфига
    const CONFIG_URL:String = "gameConfig.json";


    // Данные конфига
    var configData: Object = new Object();

    public function Main() {
       // stage.color = 0x000000;
        // Загрузка конфига
        getJson(CONFIG_URL);
    }

    private var backgroundUrl:String = ResourcesPath + "/Images/background.jpg";
    private var loader:Loader = new Loader();

    // Загрузка фона
    public function LoadBackground(): void {
        var request:URLRequest = new URLRequest(backgroundUrl);
        loader.load(request);
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
    }

    // Завершение загрузки фона. Старт первой игры
    private function loadComplete(event:Event):void {
        var myBitmap:BitmapData = new BitmapData(loader.width, loader.height, true);

        var myImage:Bitmap = new Bitmap(myBitmap);
        stage.addChildAt(myImage, 0);
        myImage.x = -450;
        myImage.y = -200;
        myBitmap.draw(loader, new Matrix());
        StartNewGame();
    }

    // Открытие окна окончания игры
    public function ShowEndGameWindow(text: String): void {
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
        btnTextFormat.size = 22;
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

        //winBtn.addEventListener(MouseEvent.CLICK, RestartBtnClick);
        btnText.addEventListener(MouseEvent.CLICK, RestartBtnClick);
    }

    // Обработка нажатия кнопки "Рестарт"
    public function RestartBtnClick(event:MouseEvent): void {
        trace("Restart button clicked");
        this.StartNewGame();
    }

    // Начало новой игры
    public function StartNewGame(): void {
        // Очистка поля, если оно существует и не пустое
        if (newScene != null && this.numChildren > 0){
            newScene.ClearField();
            this.removeChildren(0, this.numChildren - 1);
        }

        // Создание нового поля
        newScene = new Playfield(this);

        // Установка данных конфига для поля
        newScene.SetConfigData(this.configData);
        trace("game is started!");
    }

    // Установка параметров из конфига при завершении его загрузки. Запуск загрузки фона
    private function onLoaderComplete(e:Event):void{
        var loader:URLLoader = URLLoader(e.target);
        var data:Object = com.adobe.serialization.json.JSON.decode(loader.data);
        this.configData = data;
        LoadBackground();
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

package {

import classes.Playfield;
import classes.ResourceLoader;
import classes.ResourceLoaderEvent;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flashx.textLayout.formats.TextAlign;

public class Main extends Sprite {
    public var newScene: Playfield;

    // Окно окончания игры
    private var endGameWindow: Sprite = new Sprite();
    private var infoText: TextField = new TextField();
    private var winBtn: Sprite = new Sprite();
    private var btnText: TextField = new TextField();

    // Загрузчик ресурсов
    public var loader:ResourceLoader = new ResourceLoader();

    public function Main() {
        loader.LoadAll();
        loader.addEventListener(ResourceLoaderEvent.LOAD_COMPLETE, this.LoadComplete);
    }

    private function SetTextStyle(leftMargin: Number = 0, align: String = TextAlign.LEFT, fontSize: Number = 22, color: uint = 0xffffff): TextFormat{
        var infoTextFormat: TextFormat = new TextFormat();
        infoTextFormat.size = fontSize;
        infoTextFormat.color = color;
        infoTextFormat.leftMargin = leftMargin;
        infoTextFormat.align = align;
        return infoTextFormat;
    }

    private function SetTextField(x: Number, y: Number, width: Number, text: String = ""): TextField{
        var tField: TextField = new TextField();
        tField.x = x;
        tField.y = y;
        tField.width = width;
        tField.text = text;
        return tField;
    }

    private function CreateEndGameWindow(winWidth: Number = 350, winHeight: Number = 150, winBackColor: uint = 0x000000): void {
        // Параметры окна
        var winX: Number = newScene.x + (newScene.SizeX - winWidth) / 2;
        var winY: Number = newScene.y + (newScene.SizeY - winHeight) / 2;

        infoText = SetTextField(winX, winY, winWidth); infoText.wordWrap = true;

        // Параметры кнопки
        var btnWidth: Number = 125;
        var btnHeight: Number = 40;
        var restartBtnColor: uint = 0x0000ff;
        var btnX: Number = winX + (winWidth - btnWidth) / 2;
        var btnY: Number = winY + (winHeight - btnHeight) - 5;

        // Параметры текста кнопки
        btnText = SetTextField(btnX, btnY, btnWidth, "Рестарт");
        btnText.setTextFormat(SetTextStyle(0, TextAlign.CENTER));

        endGameWindow.graphics.beginFill(winBackColor);
        endGameWindow.graphics.drawRect(winX, winY, winWidth, winHeight);
        endGameWindow.graphics.endFill();

        winBtn.graphics.beginFill(restartBtnColor);
        winBtn.graphics.drawRect(btnX , btnY, btnWidth, btnHeight);
        winBtn.graphics.endFill();

        endGameWindow.addChild(infoText);
        endGameWindow.addChild(winBtn);
        endGameWindow.addChild(btnText);
    }

    // Открытие окна окончания игры
    public function ShowEndGameWindow(text: String): void {
        infoText.text = text;
        infoText.setTextFormat(SetTextStyle(10));
        infoText.wordWrap = true;

        this.addChild(endGameWindow);

        addEventListener(MouseEvent.CLICK, RestartBtnClick);
    }

    // Обработка нажатия кнопки "Рестарт"
    public function RestartBtnClick(event:MouseEvent): void {
        this.removeChild(endGameWindow);
        removeEventListener(MouseEvent.CLICK, RestartBtnClick);
        trace("Restart button clicked");
        this.StartNewGame();
    }

    // Начало новой игры
    public function StartNewGame(): void {
        // Очистка поля
        newScene.ClearField();

        // Установка данных конфига для поля
        newScene.SetConfigData(loader.configData);
        trace("game is started!");
    }

    // Выполняется после загрузки всех ресурсов
    private function LoadComplete(event:ResourceLoaderEvent):void {
        newScene = new Playfield(this);
        stage.addChildAt(loader.myImage, 0);
        loader.removeEventListener(ResourceLoaderEvent.LOAD_COMPLETE, this.LoadComplete);
        CreateEndGameWindow();
        StartNewGame();
    }
}
}

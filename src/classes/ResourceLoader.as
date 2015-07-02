/**
 * Created by mikhail on 02.07.15.
 */
package classes {
//import com.adobe.serialization.json.JSON;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Matrix;
import flash.media.Sound;
import flash.net.URLLoader;
import flash.net.URLRequest;

public class ResourceLoader extends EventDispatcher{
    public const ResourcesPath: String = "../../../Resources";

    // Файл конфига
    private const CONFIG_URL:String = ResourcesPath + "/Configs/gameConfig.json";

    // Данные конфига
    public var configData: Object = {};
    // Звуки
    public var sounds:Object = {};
    //Фон
    public var myImage:Bitmap = new Bitmap();

    private const BACKGROUND_URL:String = ResourcesPath + "/Images/background.jpg";
    public var loader:Loader = new Loader();

    public var configLoaded:Boolean = false;
    public var soundsLoaded:Boolean = false;
    public var imageLoaded:Boolean = false;

    public function ResourceLoader() {

    }

    public function LoadAll(): void{
        LoadConfig(CONFIG_URL);
        LoadBackground(BACKGROUND_URL);
        LoadSounds();
    }

    // Загрузка звуков
    public function LoadSounds(): void{
        sounds.increaseSnd = new Sound(new URLRequest(ResourcesPath + "/Sounds/bubble.mp3"));
        sounds.winSnd = new Sound(new URLRequest(ResourcesPath + "/Sounds/win.mp3"));
        sounds.loseSnd = new Sound(new URLRequest(ResourcesPath + "/Sounds/lose.mp3"));

        soundsLoaded = true;
        CheckLoad();
    }

    // Загрузка фона
    public function LoadBackground(backgroundUrl: String): void {
        var request:URLRequest = new URLRequest(backgroundUrl);
        loader.load(request);
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, BackgroundLoadComplete);
    }

    // Завершение загрузки фона
    public function BackgroundLoadComplete(event:Event):void {
        var myBitmap:BitmapData = new BitmapData(loader.width, loader.height, true);

        var myImage:Bitmap = new Bitmap(myBitmap);
        //stage.addChildAt(myImage, 0);
        myImage.x = -450;
        myImage.y = -200;
        myBitmap.draw(loader, new Matrix());

        imageLoaded = true;
        CheckLoad();
    }

    // Установка параметров из конфига при завершении его загрузки
    private function onLoaderComplete(e:Event):void{
        var loader:URLLoader = URLLoader(e.target);
        var data:Object = JSON.parse(loader.data);
        this.configData = data;

        configLoaded = true;
        CheckLoad();
    }

    // Получение JSON из файла-конфига
    function LoadConfig(fileName: String): void{
        var urlRequest:URLRequest  = new URLRequest(fileName);
        var urlLoader:URLLoader = new URLLoader();
        urlLoader.addEventListener(Event.COMPLETE, onLoaderComplete);

        try{
            urlLoader.load(urlRequest);
        } catch (error:Error) {
            trace("Cannot load : " + error.message);
        }
    }

    // Проверяет загружены ли все ресурсы
    public function CheckLoad(): void{
        if (configLoaded && imageLoaded && soundsLoaded){
            dispatchEvent(new ResourceLoaderEvent(ResourceLoaderEvent.LOAD_COMPLETE));
        }
    }
}
}

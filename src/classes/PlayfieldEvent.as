/**
 * Created by mikhail on 20.06.15.
 */
package classes {
import flash.events.Event;

public class PlayfieldEvent extends Event {
    public function PlayfieldEvent(type: String) {
        super(type);
    }

    // Игра стартовала
    public static const GAME_STARTED:String = "game_started";

    // Игра завершилась
    public static const GAME_FINISHED:String = "game_finished";
}
}

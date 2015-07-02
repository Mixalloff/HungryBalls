/**
 * Created by mikhail on 02.07.15.
 */
package classes {
import flash.events.Event;

public class ResourceLoaderEvent extends Event{
    public function ResourceLoaderEvent(type:String) {
        super(type);
    }

    public static const LOAD_COMPLETE:String = "complete";
}
}

package core.forms {
	import flash.events.Event;

	/**
	 * @author ted
	 */
	public interface IFormContainer {
		//function populate () : void;
		function getValues (_value : * ) : String;
		function sendForm ( e:Event=null) : void;
	}
}

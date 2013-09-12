package core.forms {
	import flash.events.Event;

	/**
	 * @author ted
	 */
	public class FormEvent extends Event {
		
		public var data : *;
		public static const SUCCESS  : String = 'success';
		public static const SENDING : String = 'sending';
		public static const ERROR : String = 'error';
		public static const FAILED : String = 'failed';
		
		public function FormEvent(type : String, data : * = null) {
			super(type, true, false);
			this.data = data;
		}
		override public function clone():Event{
			return new FormEvent(this.data);
		}
	}
}

package core.sound {
	import flash.events.Event;

	/**
	 * @author anthonysapp
	 */
	public class SoundManagerEvent extends Event {
		public static const MUTE_ALL_SOUNDS : String = "muteAll";
		public static const UNMUTE_ALL_SOUNDS : String = "unmuteAll";
		public static const UNMUTE_SOUND : String = "unMute";
		public static const MUTE_SOUND : String = "muteSound";

		public var soundID:String;
		public var exceptions:Array;
		
		public function SoundManagerEvent(type : String, soundID:String = null, exceptions:Array = null) {
			super(type, false, false);
			this.soundID = soundID;
			this.exceptions = exceptions;
		}
		override public function clone():Event{
			return new SoundManagerEvent (type, soundID, exceptions);
		}
	}
}

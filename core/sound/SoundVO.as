package core.sound {
	import flash.media.SoundChannel;
	import flash.media.Sound;

	/**
	 * @author anthonysapp
	 */
	public class SoundVO {
		public var id:String;
		public var sound:Sound;
		public var soundChannel:SoundChannel;
		public var volume:Number =0;
		public var pan:Number = 0;
		public var loops:int = 0;
		public var startTime:Number = 0;
		public var fadeInTime:Number = 0;
		public var paused:Boolean = false;
		public var mute:Boolean = false;
		public var playing:Boolean = false;
		public var pausePosition : Number = 0;
		public var infinite:Boolean = false;
		public var mutedVolume : Number;
	}
}

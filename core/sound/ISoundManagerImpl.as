package core.sound {
	import flash.media.Sound;
	import flash.events.Event;

	/**
	 * @author anthonysapp
	 */
	public interface ISoundManagerImpl {
		function registerSound(soundID : String, sound : Sound,  loops:int= 0, startVolume:Number = 1) : *;

		function unregisterSound(soundID : String) : void;

		function playSound(soundID : String, startTime : Number = 0,loops : int = 0, fadeInTime : Number = 0, volume : Number = 1,pan:Number = 0,overwrite:Boolean = true, resume:Boolean = false) : void;

		function stopSound(soundID : String, fadeOutTime : Number = 0,unRegister : Boolean = true) : void;

		function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 1,useWeakReference : Boolean = false) : void;

		function removeEventListener(type : String, listener : Function,useCapture : Boolean = false) : void;

		function dispatchEvent(event : Event) : Boolean;
		
		function getSound(soundID:String):Sound;
		
		function muteSound(soundID : String,fadeOutTime : Number = 0) : void;
		function pauseSound(soundID : String) : void;
		function resumeSound(soundID : String, fadeInTime:Number = 0, volume:Number = -1) : void;
		
		function setSoundVolume(soundID : String, volume:Number, fadeTime : Number = 0) : void

		function muteAll(fadeOutTime : Number = 0, exceptions:Array= null) : void;

		function unMuteAll(playSounds:Boolean = false, fadeInTime:Number = 0) : void;

		function unMute(soundID : String) : void;

		function panSound(soundID : String, amount : Number, panTime : Number = 0, ease : * = null) : void;
	}
}

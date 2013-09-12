package core.sound {
	import flash.media.Sound;
	import flash.events.Event;

	/**
	 * @author anthonysapp
	 */
	public class SoundManager {
		public static var mute : Boolean = false;
		public static var muteNewSounds : Boolean = false;
		private static var _impl : ISoundManagerImpl;
		private static var allowInstantiation : Boolean;

		public function SiteManager() : void {
			if (!allowInstantiation) {
				throw new Error("Error: Instantiation failed: Use SiteManager.getInstance() instead of new.");
			}
		}

		public static function get impl() : ISoundManagerImpl {
			if (_impl == null) {
				allowInstantiation = true;
				_impl = getImpl();
				allowInstantiation = false;
			}
			return _impl;
		}

		private static function getImpl() : ISoundManagerImpl {
			return new SoundManagerImpl();
		}

		public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 1, useWeakReference : Boolean = false) : void {
			impl.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void {
			impl.removeEventListener(type, listener, useCapture);
		}

		public function dispatchEvent(event : Event) : Boolean {
			return impl.dispatchEvent(event);
		}

		public static function getSound(soundID : String) : Sound {
			return impl.getSound(soundID);
		}

		public static function registerSound(soundID : String, sound : Sound, loops : int = 0, startVolume : Number = 1) : * {
		  impl.registerSound(soundID, sound, loops, startVolume);
		}

		public static function playSound(soundID : String, startTime : Number = 0,loops : int = 0, fadeInTime : Number = 0, volume : Number = 1,pan : Number = 0, overwrite : Boolean = true,resume : Boolean = false) : void {
			impl.playSound(soundID, startTime, loops, fadeInTime, volume, pan, overwrite, resume);
		}

		public static function stopSound(soundID : String,  fadeOutTime : Number = 0,unRegister : Boolean = true) : void {
			impl.stopSound(soundID, fadeOutTime, unRegister);
		}

		public static function setSoundVolume(soundID : String, volume : Number, fadeTime : Number = 0) : void {
			impl.setSoundVolume(soundID, volume, fadeTime);
		}

		public static function muteSound(soundID : String, fadeOutTime : Number = 0) : void {
			impl.muteSound(soundID, fadeOutTime);
		}

		public static function pauseSound(soundID : String) : void {
			impl.pauseSound(soundID);
		}

		public static function resumeSound(soundID : String, fadeInTime : Number = 1, volume : Number = -1) : void {
			impl.resumeSound(soundID, fadeInTime, volume);
		}

		public static function muteAll(fadeOutTime : Number = 0, ...exceptions) : void {
			muteNewSounds = true;
			impl.muteAll(fadeOutTime, exceptions);
		}

		public static function unMuteAll(playSounds:Boolean = false, fadeInTime:Number = 0) : void {
			muteNewSounds = false;
			mute = false;
			impl.unMuteAll(playSounds, fadeInTime);
		}

		public static function unMute(soundID : String) : void {
			impl.unMute(soundID);
		}

		public static function panSound(soundID : String, amount : Number, panTime : Number = 0, ease : * = null) : void {
			impl.panSound(soundID, amount, panTime, ease);
		}

		public static function addEventListener(type : String, listener : Function) : void {
			impl.addEventListener(type, listener);
		}
	}
}

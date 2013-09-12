package core.sound {
	import core.sound.SoundVO;
	import core.sound.SoundManagerEvent;

	import flash.events.Event;

	import gs.easing.Linear;

	import core.q.QLibrary;

	import gs.easing.Sine;
	import gs.TweenMax;

	import flash.media.SoundTransform;
	import flash.media.SoundChannel;
	import flash.utils.Dictionary;

	import core.sound.ISoundManagerImpl;

	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.media.Sound;

	/**
	 * @author anthonysapp
	 * this class is a work in progress!
	 */
	public class SoundManagerImpl extends EventDispatcher implements ISoundManagerImpl {
		private var _dict : Dictionary;
		private var muteExceptions : Array;
		private var _channels : Dictionary;

		
		public function SoundManagerImpl(target : IEventDispatcher = null) {
			super(target);
		}

		public function isSoundPlaying(soundID) : Boolean {
			return (_dict[soundID] as SoundVO).playing;
		}

		public function getSound(soundID : String) : Sound {
			return (_dict[soundID] as SoundVO).sound;
		}

		public function registerSound(soundID : String, sound : Sound, loops : int = 0, startVolume : Number = 1) : * {
			checkDictionaries();
			var svo : SoundVO = new SoundVO();
			svo.id = soundID;
			svo.sound = sound;
			svo.loops = loops;
			svo.infinite = svo.loops == int.MAX_VALUE;
			svo.volume = startVolume;
			svo.mute = getMute(soundID);
			_dict[soundID] = svo;
			return svo;
		}

		private function getMute(soundID : String) : Boolean {
			if (SoundManager.mute) return true;
			if (muteExceptions != null) {
				return muteExceptions.indexOf(soundID) == -1;
			}
			return false;
		}

		public function unregisterSound(soundID : String) : void {
			var svo : SoundVO = _dict[soundID];
			delete _channels[svo.soundChannel];
			delete _dict[soundID];
			if (svo == null)return;
			try {
				svo.soundChannel.stop();
				svo.soundChannel = null;
				svo = null;
			}catch (e : *) {
				return;
			}
		}

		public function pauseSound(soundID : String) : void {
			stopSound(soundID, 0, false);
		}

		public function resumeSound(soundID : String,fadeInTime : Number = 0, volume : Number = 0) : void {
			if (!soundExists(soundID))return;
			var svo : SoundVO = _dict[soundID];
			playSound(soundID, svo.pausePosition, svo.loops, fadeInTime, svo.pan, volume, false, true);
		}

		public function playSound(soundID : String, startTime : Number = 0,loops : int = 0, fadeInTime : Number = 0, volume : Number = 1,pan : Number = 0,overwrite : Boolean = true, resume : Boolean = false) : void {
			checkDictionaries();
			try {
				var svo : SoundVO;
				var sound : Sound;
				var sc : SoundChannel;
				var st : SoundTransform;
			
				if (soundExists(soundID)) {
					svo = _dict[soundID];
					sc = svo.soundChannel;
					svo.volume = volume;
				} else {
					svo = registerSound(soundID, QLibrary.getFileById(soundID).asset as Sound, loops, volume);
					svo.pan = pan;
					svo.volume = volume;
					st = new SoundTransform(fadeInTime > 0 ? 0 : svo.volume, svo.pan);
				}
				if (svo.mute || SoundManager.mute || (svo.playing && !overwrite) )return;
				sound = svo.sound;
				TweenMax.killTweensOf(svo.soundChannel);
				st = svo.soundChannel == null ? new SoundTransform(fadeInTime > 0 ? 0 : svo.volume, svo.pan) : svo.soundChannel.soundTransform;	
				st.volume = volume;
				if (overwrite) {
					sc = new SoundChannel();
					st = new SoundTransform(0, svo.pan);
					sc.soundTransform = st;
					sc.stop();
				}
				sc = sound.play(overwrite == false ? resume ? svo.paused ? svo.pausePosition : 0 : 0 : startTime, loops, st);
				
				svo.soundChannel = sc;
				_channels[sc] = svo;
			
				svo.playing = true;
				svo.paused = false;
			
				if (fadeInTime > 0) {
					TweenMax.to(sc, fadeInTime, {volume:svo.volume, ease:Sine.easeOut});
				} else {
					st.volume = volume;
					sc.soundTransform = st;
				}
				sc.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
				sc.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			}catch (e : Error) {
				/*try {
					trace('The sound: ' + svo.id + ' could not be played due to the following error: ' + e.getStackTrace());
				}catch(e2 : *) {
				}*/
			}
		}

		private function soundExists(soundID : String) : Boolean {
			if (_dict == null)return false;
			return _dict[soundID] == null ? false : true;
		}

		private function checkDictionaries() : void {
			if (_dict == null)_dict = new Dictionary();
			if (_channels == null)_channels = new Dictionary();
		}

		private function onSoundComplete(event : Event) : void {
			dispatchEvent(event);
			(event.target as SoundChannel).removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			var svo : SoundVO = _channels[event.target];
			svo.playing = false;
			if (svo.infinite) playSound(svo.id, svo.startTime, svo.loops, 0, svo.volume, svo.pan);
		}

		public function stopSound(soundID : String, fadeOutTime : Number = 0, unRegister : Boolean = true) : void {
			if (!soundExists(soundID))return;
			
			var svo : SoundVO = _dict[soundID];
			var sc : SoundChannel = svo.soundChannel;
			if (sc == null)return;
			try {
				if (fadeOutTime > 0) {
					TweenMax.to(sc, fadeOutTime, {volume:0, ease:Sine.easeOut, onComplete:doUnRegisterOnStop, onCompleteParams:[soundID, unRegister]});
				} else {
					doUnRegisterOnStop(soundID, unRegister);
				}
			}catch (e : *) {
			}
		}

		private function doUnRegisterOnStop(soundID : String, unRegister : Boolean) : void {
			if (unRegister) {
				unregisterSound(soundID);
				return;
			}
			try {
				var svo : SoundVO = _dict[soundID];
				svo.paused = true;
				svo.pausePosition = svo.soundChannel.position;
				svo.soundChannel.stop();
			}catch (e : *) {
			}
		}

		private function updateChannel(soundID : String, sc : SoundChannel,st : SoundTransform) : void {
			var svo : SoundVO = _dict[soundID];
			sc.soundTransform = st;
			svo.soundChannel = sc;
			svo.volume = st.volume;
			svo.pan = st.pan;
		}

		public function setSoundVolume(soundID : String, volume : Number, fadeTime : Number = 0) : void {
			if (!soundExists(soundID))return;
			var svo : SoundVO = _dict[soundID];
			if ((svo.mute || SoundManager.mute) && volume > 0)return;
			try {
				var sc : SoundChannel = svo.soundChannel;
				var st : SoundTransform = sc.soundTransform;
				if (st.volume == volume)return;
			
				if (fadeTime > 0) {
					TweenMax.to(sc, fadeTime, {volume:volume, ease:Sine.easeOut});
				} else {
					st.volume = volume;
					updateChannel(soundID, sc, st);
				}
			}catch (e : *) {
				try {
					playSound(soundID, 0, 0, fadeTime, volume);
				}catch (e : *) {
				}
			}
		}

		public function panSound(soundID : String, amount : Number, panTime : Number = 0, ease : * = null) : void {
			if (!soundExists(soundID))return;
			var svo : SoundVO = _dict[soundID];
			if (svo.mute || SoundManager.mute)return;
			
			var sc : SoundChannel = svo.soundChannel;
			var st : SoundTransform = sc.soundTransform;
			
			if (panTime > 0) {
				TweenMax.to(sc, panTime, {pan:amount, ease:Linear.easeNone});
			} else {
				st.pan = amount;
				updateChannel(soundID, sc, st);
			}
		}

		public function unMute(soundID : String) : void {
			if (!soundExists(soundID))return;
			
			var svo : SoundVO = _dict[soundID];
			svo.mute = false;
			
			dispatchEvent(new SoundManagerEvent(SoundManagerEvent.UNMUTE_SOUND, soundID));
		}

		public function unMuteAll(playSounds : Boolean = false, fadeInTime : Number = 0) : void {
			muteExceptions = null;
			for each (var svo:SoundVO in _dict) {
				svo.mute = false;
				if (playSounds) {
					playSound(svo.id, svo.pausePosition, svo.loops, fadeInTime, svo.mutedVolume);
				}
			}
			dispatchEvent(new SoundManagerEvent(SoundManagerEvent.UNMUTE_ALL_SOUNDS));
		}

		public function muteSound(soundID : String, fadeOutTime : Number = 0) : void {
			var svo : SoundVO = _dict[soundID];
			svo.mutedVolume = svo.volume;
			svo.mute = true;
			TweenMax.killTweensOf(svo.soundChannel);
			setSoundVolume(soundID, 0, fadeOutTime);
			dispatchEvent(new SoundManagerEvent(SoundManagerEvent.MUTE_SOUND, soundID));
		}	

		public function muteAll(fadeOutTime : Number = 0, exceptions : Array = null) : void {
			muteExceptions = exceptions;
			if (_dict == null)return;
			var svo : SoundVO;
			
			if (muteExceptions.length == 0) {
				for each (svo in _dict) {
					muteSound(svo.id);
				}
			} else {
				for each (svo in _dict) {
					if (muteExceptions.indexOf(svo.id) > -1)continue;
					muteSound(svo.id);
				}
			}
			dispatchEvent(new SoundManagerEvent(SoundManagerEvent.MUTE_ALL_SOUNDS, null, muteExceptions));
		}
	}	
}

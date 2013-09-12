package core.display {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.Event;	
	import flash.display.MovieClip;

	/**
	 * @author Sapp
	 */
	public class StateClip extends MovieClip {
		public static const STOP_MODE : String = 'stateClipStopMode';
		public static const PLAY_MODE : String = 'stateClipPlayMode';
		public static const SILENT_MODE : String = 'stateClipSilentMode';
		public static const FUNCTION_MODE : String = 'stateClipFunctionMode';
		//
		protected var _state : String;
		protected var _mode : String = StateClip.PLAY_MODE;
		public var delay : Number = 0;

		private var _timer : Timer;

		public function StateClip() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		public function onAddedToStage(event : Event = null) : void {
			if (totalFrames == 1) mode = StateClip.SILENT_MODE;		
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			
			init();
			setup();
		}

		public function init() : void {
		}

		public function setup() : void {
		}

		
		
		public function destroy() : void {
		}

		public function onRemovedFromStage(event : Event = null) : void {
			killTimer();
			destroy();
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false);
		}

		
		
		protected function setState() : void {
			if (_state != null) {
				switch (mode) {
					case StateClip.FUNCTION_MODE:
						try {
							this[_state]();
						}catch (e : *) {
							trace(e);
						}
						break;
					case StateClip.STOP_MODE:
						gotoAndStop(_state);
						break;
					case StateClip.PLAY_MODE:
						gotoAndPlay(_state);
						break;
					case StateClip.SILENT_MODE:
						//nothing
						break;
				}
			}
			dispatchEvent(new Event(Event.CHANGE, true));
		}

		public function get state() : String {
			return _state;
		}

		public function set state(value : String) : void {
			if (_state == value) return;
			_state = value;
			if (delay > 0) {
				setTimer();
				return;
			}
			try {
				setState();
			}catch(e : *) {
			}
		}

		protected function killTimer() : void {
			if (_timer != null) {
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				_timer.stop();
				_timer = null;
			}
		}

		protected function setTimer() : void {
			if (_timer == null) {
				_timer = new Timer(delay * 1000, 1);
			} else {
				_timer.delay = delay * 1000;
			}
			addTimerListeners();
			_timer.start();
		}

		protected function addTimerListeners() : void {
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
		}

		protected function onTimerComplete(event : TimerEvent) : void {
			killTimer();
			try {
				setState();
			}catch (e : *) {
			}
		}

		public function get mode() : String {
			return _mode;
		}

		public function set mode(value : String) : void {
			_mode = value;
		}	
	}
}

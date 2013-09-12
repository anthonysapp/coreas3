package core.display {
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.Event;	

	/**
	 * @author Sapp
	 */
	public class StateSprite extends Sprite {
		public static const NORMAL_MODE : int = 0;
		public static const FUNCTION_MODE : int = 1;
		//
		protected var _state : String;
		
		public var mode : int = NORMAL_MODE;
		public var delay : Number = 0;

		private var _timer : Timer;

		public function StateSprite() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		public function onAddedToStage(event : Event = null) : void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			init();
			setup();
		}

		public function init() : void {
		}

		public function setup() : void {
		}

		public function onRemovedFromStage(event : Event = null) : void {
			killTimer();
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			destroy();
		}

		public function destroy() : void {
		}

		protected function setState() : void {
			dispatchEvent(new Event(Event.CHANGE, true));
			if (mode == FUNCTION_MODE)try{this[_state]();}catch (e:*){trace (e)}
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

		private function addTimerListeners() : void {
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
		}

		private function onTimerComplete(event : TimerEvent) : void {
			killTimer();
			try {
				setState();
			}catch (e : *) {
			}
		}

		public function get state() : String {
			return _state;
		}
		public function set state (value:String):void{
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
	}
}

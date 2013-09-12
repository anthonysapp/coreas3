package core.utils {
	import flash.display.StageDisplayState;

	import core.interfaces.IResizeable;	

	import flash.events.Event;	
	import flash.utils.Dictionary;	
	import flash.display.Stage;	

	/**
	 * @author anthonysapp
	 */
	public class StageUtil {
		public static var HALF_X : Number;
		public static var HALF_Y : Number;
		public static var MIN_WIDTH : Number;
		public static var MIN_HEIGHT : Number;
		public static var SCALE : Number = 1;
		public static var sw : Number;
		public static var sh : Number;
		public static var scale : Number;

		private static var _minWidth : Number = -1;
		private static var _minHeight : Number = -1;
		private static var _initialized : Boolean = false;
		private static var _stage : Stage;
		private static var _dict : Dictionary;
		private static var _initialWidth : Number;		private static var _initialHeight : Number;
		private static var _sx : Number;
		private static var _sy : Number;

		public static function initialize(stageReference : Stage, minWidth : Number = 955, minHeight : Number = 600) : void {
			if (_initialized) return;
			_stage = stageReference;
			
			_minWidth = minWidth;
			_minHeight = minHeight;
			
			_initialWidth = _stage.stageWidth;			_initialHeight = _stage.stageHeight;
			
			setProps();
			
			_stage.addEventListener(Event.RESIZE, onStageResize);
			_initialized = true;
		}

		public static function toggleFullScreen() : void {
			if (!_initialized) {
				throw (new Error('StageUtil:: cannot change display state until passed a stage reference'));
				return;
			}
			try {
				_stage.displayState = stage.displayState == StageDisplayState.FULL_SCREEN ? StageDisplayState.NORMAL : StageDisplayState.FULL_SCREEN;
			}catch (e : Error) {
				trace('StageUtil:: error toggling fullscreen mode due to the following error stack:: \n' + e.getStackTrace());
			}
		}

		private static function setProps() : void {
			sw = _stage.stageWidth;
			sh = _stage.stageHeight;
			
			_sx = sw / StageUtil._initialWidth;
			_sy = sh / StageUtil._initialHeight;
			
			scale = _sx >= 1 && _sy >= 1 ? 1 : _sx > _sy ? _sy : _sx;
			
			MIN_WIDTH = _minWidth < 0 ? sw : sw <= _minWidth ? _minWidth : sw;
			MIN_HEIGHT = _minHeight < 0 ? sh : sh <= _minHeight ? _minHeight : sh ;
			
			HALF_X = MIN_WIDTH / 2;
			HALF_Y = MIN_HEIGHT / 2;
		}

		public static function get stage() : Stage {
			return _stage;
		}

		public static function registerResizeableObject(oResizeable : IResizeable, autoUpdate : Boolean = true) : void {
			if (_dict == null)_dict = new Dictionary(true);
			_dict[oResizeable] = oResizeable;
			if (autoUpdate)oResizeable.onStageResize();
		}

		public static function unRegisterResizeableObject(oResizeable : IResizeable) : void {
			delete _dict[oResizeable];
		}

		public static function onStageResize(event : Event) : void {
			
			setProps();
			
			for each (var oResizeable:IResizeable in _dict) {
				oResizeable.onStageResize();
			}
		}
	}
}

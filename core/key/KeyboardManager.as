package core.key {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;

	/**
	 * @author anthonysapp
	 */
	public class KeyboardManager {
		protected static var initialized : Boolean = false;
		
		private static var disp : EventDispatcher;
		private static var dict : Dictionary;
		private static var storage:Dictionary;

		private static var keyDownFunctions : Dictionary;
		private static var keyUpFunctions : Dictionary;

		private static var active : Boolean = false;
		public static var enabled:Boolean = true;
		
		public static function initialize(stageReference : DisplayObject) : void {
			if (initialized)return;			
			
			createDictionaries();
			
			stageReference.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
			stageReference.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
			stageReference.addEventListener(Event.ACTIVATE, _activate);
			stageReference.addEventListener(Event.DEACTIVATE, _deactivate);
			active = true;
			initialized = true;
		}

		private static function _deactivate(event : Event) : void {
			active = false;
			for (var keyCode in dict) {
				dict[keyCode] = false;
			}
		}

		private static function _activate(event : Event) : void {
			active = true;
		}

		private static function createDictionaries() : void {
			if (dict == null)dict = new Dictionary();
			if (disp == null)disp = new EventDispatcher();
			
			
			if (keyDownFunctions == null)keyDownFunctions = new Dictionary();
			if (keyUpFunctions == null)keyUpFunctions = new Dictionary();
			if (storage == null)storage = new Dictionary();
		}

		public static function isKeyDown(keyCode : int) : Boolean {
			if (!initialized || !active)return false;
			if (dict[keyCode] == null)return false;
			return dict[keyCode];
		}

		public static function registerKeyDownFunction(keyCode : int,  func : Function, ...args) : void {
			if (keyDownFunctions == null)return;
			if (keyDownFunctions[keyCode] == null)keyDownFunctions[keyCode] = new Dictionary();
			keyDownFunctions[keyCode][{func:func, args:args}] = func;
		}

		public static function unRegisterKeyDownFunction(keyCode : int,  func : Function) : void {
			for (var obj in keyDownFunctions[keyCode]) {
				if (obj.func == func)delete keyDownFunctions[keyCode][obj];
			}
		}

		public static function registerKeyUpFunction(keyCode : int, func : Function, ...args) : void {
			if (keyUpFunctions[keyCode] == null)keyUpFunctions[keyCode] = new Dictionary();
			keyUpFunctions[keyCode][{func:func, args:args}] = func;
		}

		public static function unRegisterKeyUpFunction(keyCode : int,  func : Function) : void {
			for (var obj in keyUpFunctions[keyCode]) {
				if (obj.func == func)delete keyUpFunctions[keyCode][obj];
			}
		}

		private static function updateKeyDownFunctions(keyCode : int) : void {
			for (var obj in keyDownFunctions[keyCode]) {
				keyDownFunctions[keyCode][obj].apply(null, obj.args);
			}
		}

		private static function updateKeyUpFunctions(keyCode : int) : void {
			for (var obj in keyUpFunctions[keyCode]) {
				keyUpFunctions[keyCode][obj].apply(null, obj.args);
			}
		}

		private static function _onKeyUp(event : KeyboardEvent) : void {
			if (!enabled)return;
			dict[event.keyCode] = false;
			dispatchEvent(event);
			updateKeyUpFunctions(event.keyCode);
		}

		private static function _onKeyDown(event : KeyboardEvent) : void {
			if (!enabled)return;
			dict[event.keyCode] = true;
			dispatchEvent(event);
			updateKeyDownFunctions(event.keyCode);
		}

		public static function dispatchEvent(event : Event) : void {
			if (disp == null)disp = new EventDispatcher();
			disp.dispatchEvent(event);
		}

		public static function addEventListener(type : String, listener : Function,useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void {
			if (disp == null)disp = new EventDispatcher();
			disp.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public static function removeEventListener(type : String, listener : Function) : void {
			if (disp == null)disp = new EventDispatcher();
			disp.removeEventListener(type, listener);
		}
		public static function storeKeys(id : String) : void {
			if (storage == null)storage = new Dictionary();
			storage[id] = {keyUpFunctions:keyUpFunctions, keyDownFunctions:keyDownFunctions};
			
			keyUpFunctions = null;
			keyDownFunctions = null;
		}
	}
}

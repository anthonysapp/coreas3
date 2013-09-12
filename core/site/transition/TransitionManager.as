package core.site.transition {
	import core.site.interfaces.IPageComponent;
	import core.site.SiteFacade;

	import com.adobe.utils.DictionaryUtil;

	import flash.utils.Dictionary;

	import core.site.interfaces.IPage;

	import flash.events.EventDispatcher;

	/**
	 * @author anthonysapp
	 */
	public class TransitionManager extends EventDispatcher {
		//
		public static const PAGES : String = 'pages';
		public static const COMPONENTS : String = 'components';
		//
		public static const TRANSITION_IN : String = 'transitionIn';
		public static const TRANSITION_OUT : String = 'transitionOut';
		//
		protected static var instance : TransitionManager;
		protected static var phase : String;
		//
		public var isTransitioning : Object = {transitionIn:false, transitionOut:false };
		public var transitionsRemaining : Object = {transitionIn:0, transitionOut:0};		public var componentTransitions : Dictionary = new Dictionary();
		public var componentTransitionsRemaining : Object = {transitionIn:0, transitionOut:0};
		public  var transitionIndex : Object = {transitionIn:0, transitionOut:0};

		public  var minPageChangeLevel : Object = {transitionIn:-1, transitionOut:-1};
		public  var maxPageChangeLevel : Object = {transitionIn:0, transitionOut:0};

		public  var minComponentChangeLevel : Object = {transitionIn:-1, transitionOut:-1};
		public  var maxComponentChangeLevel : Object = {transitionIn:0, transitionOut:0};

		public var pageTransitions : Dictionary = new Dictionary();
		public var transitions : Array = new Array();
		//
		public static var callbackFunction : Function;
		public static var argArray : Array;
		protected var pageChangeLevel : int = 0;

		
		public static function addEventListener(type : String, listener : Function) : void {
			getInstance().addEventListener(type, listener);
		}

		public static function removeEventListener(type : String, listener : Function) : void {
			getInstance().addEventListener(type, listener);
		}

		public static function doTransitions(transitionDirection : String, callback : Function = null, ...args) : void {
			if (transitionDirection == TransitionManager.TRANSITION_IN) {
				SiteFacade.getInstance().beforeTransitionIn();
			} else {
				SiteFacade.getInstance().beforeTransitionOut();
			}
			if (getPageTransitionsRemaining(transitionDirection) > 0 || getComponentTransitionsRemaining(transitionDirection) > 0) {
				startTransitions(transitionDirection);
				return;
			}
			if (callback != null) {
				callback.apply(null, args);
			}
			getInstance().transitionsComplete(transitionDirection);
		}

		public static function registerPageTransition(direction : String, pageToRegister : IPage) : void {
			getInstance()._registerPageTransition(direction, pageToRegister);
		}

		public static function registerComponentTransition(direction : String, componentToRegister : IPageComponent) : void {
			getInstance()._registerComponentTransition(direction, componentToRegister);
		}

		public static function removePageTransition(transitionDirection : String, pageToRemove : IPage) : void {
			getInstance()._removePageTransition(transitionDirection, pageToRemove);
		}

		public static function removeComponentTransition(transitionDirection : String, componentToRemove : IPageComponent) : void {
			getInstance()._removeComponentTransition(transitionDirection, componentToRemove);
		}

		public static function startTransitions(transitionDirection : String) : void {
			getInstance().pageChangeLevel = SiteFacade.getInstance().getPageChangeLevel();
			getInstance()._startTransitions(transitionDirection);
		}

		private function _startTransitions(transitionDirection : String) : void {
			if (transitionDirection == TransitionManager.TRANSITION_IN) {
				if (DictionaryUtil.dictionaryHasItems(pageTransitions[transitionDirection])) {
					transitionIndex[transitionDirection] = minPageChangeLevel[transitionDirection];
				} else {
					transitionIndex[transitionDirection] = minComponentChangeLevel[transitionDirection];
				}
			} else {
				if (DictionaryUtil.dictionaryHasItems(pageTransitions[transitionDirection])) {
					transitionIndex[transitionDirection] = maxPageChangeLevel[transitionDirection];
				} else {
					transitionIndex[transitionDirection] = maxComponentChangeLevel[transitionDirection];
				}
			}
			isTransitioning[transitionDirection] = true;
			_initTransitionQueue(transitionDirection);
		}

		private function _initTransitionQueue(transitionDirection : String) : void {
			//trace('_initTransitionQueue ' + transitionDirection + ' index: ' + transitionIndex[transitionDirection])
			if (DictionaryUtil.dictionaryHasItems(pageTransitions[transitionDirection]) || DictionaryUtil.dictionaryHasItems(componentTransitions[transitionDirection])) {
				if (transitionDirection == TransitionManager.TRANSITION_OUT) {
					if (componentTransitions[transitionDirection] != null) { 
						if (componentTransitions[transitionDirection][transitionIndex[transitionDirection]] != null) {
							doComponentTransitions(transitionDirection);
							return;
						}
					}
				}
				if (pageTransitions[transitionDirection] != null) {
					if (pageTransitions[transitionDirection][transitionIndex[transitionDirection]] != null) {
						for each (var aPage:IPage in pageTransitions[transitionDirection][transitionIndex[transitionDirection]]) {
							if(transitionDirection == TRANSITION_IN) {
								aPage.transitionIn(); 
							} else {
								aPage.transitionOut();
							}
						}
						return;
					}
				}
				if (componentTransitions[transitionDirection] != null) {
					if (componentTransitions[transitionDirection][transitionIndex[transitionDirection]] != null) {
						doComponentTransitions(transitionDirection);
					} else {
						changeTransitionIndex(transitionDirection);
						_initTransitionQueue(transitionDirection);
					}
					return;
				}
				changeTransitionIndex(transitionDirection);
				if (transitionIndex[transitionDirection] <= maxPageChangeLevel[transitionDirection])_initTransitionQueue(transitionDirection);
				return;
			}
			
			isTransitioning[transitionDirection] = false;
			SiteFacade.getInstance().afterAllTransitions();
		}

		private function changeTransitionIndex(transitionDirection : String) : void {
			if (transitionDirection == TransitionManager.TRANSITION_IN) {
				transitionIndex[transitionDirection]++; 
			} else {
				transitionIndex[transitionDirection]--;
			}
		}

		private function doComponentTransitions(transitionDirection : String) : void {
			//trace('doComponentTransitions:: ' + transitionDirection)
			for each (var aPageComponent:IPageComponent in componentTransitions[transitionDirection][transitionIndex[transitionDirection]]) {
				if(transitionDirection == TRANSITION_IN) {
					aPageComponent.transitionIn(); 
				} else {
					aPageComponent.transitionOut();
				}
			}
		}

		
		
		private function transitionsComplete(transitionDirection : String) : void {
			delete pageTransitions[transitionDirection];
			maxPageChangeLevel[transitionDirection] = maxComponentChangeLevel[transitionDirection] = transitionIndex[transitionDirection] = 0;
			minPageChangeLevel[transitionDirection] = minComponentChangeLevel[transitionDirection] = -1;
			if (transitionDirection == TransitionManager.TRANSITION_IN) { 
				SiteFacade.getInstance().afterTransitionIn();
			} else {
				SiteFacade.getInstance().afterTransitionOut();
			}
		}

		
		private function _registerPageTransition(transitionDirection : String,pageToRegister : IPage) : void {
			//trace('reg page transition: dir: ' + transitionDirection + ' page: ' + pageToRegister + ' level: ' + pageToRegister.getLevel());
			var level : int = pageToRegister.getLevel();
			var id : String = pageToRegister.getPageID();
			
			if (pageTransitions[transitionDirection] == null)pageTransitions[transitionDirection] = new Dictionary();
			if (pageTransitions[transitionDirection][level] == null) {
				pageTransitions[transitionDirection][level] = new Dictionary();
			}
			if (pageTransitions[transitionDirection][level][id] == null) {
				pageTransitions[transitionDirection][level][id] = pageToRegister;
				transitionsRemaining[transitionDirection]++;
			}
			if ( minPageChangeLevel[transitionDirection] == -1 || level < minPageChangeLevel[transitionDirection])minPageChangeLevel[transitionDirection] = level;
			if (level > maxPageChangeLevel[transitionDirection])maxPageChangeLevel[transitionDirection] = level;
		}

		private function _removePageTransition(transitionDirection : String,pageToRemove : IPage) : void {
			var level : int = pageToRemove.getLevel();
			var id : String = pageToRemove.getPageID();
			
			if (pageTransitions[transitionDirection][level] == null)return;
			if (pageTransitions[transitionDirection][level][id] != null) {
				delete pageTransitions[transitionDirection][level][id];
				transitionsRemaining[transitionDirection]--;
				if (isTransitioning[transitionDirection]) {
					if (!DictionaryUtil.dictionaryHasItems(pageTransitions[transitionDirection][level])) {
						delete pageTransitions[transitionDirection][level];
						if (!DictionaryUtil.dictionaryHasItems(pageTransitions[transitionDirection])) {
							delete (pageTransitions[transitionDirection]);
						}
						if (transitionsRemaining[transitionDirection] == 0 && componentTransitionsRemaining[transitionDirection] == 0) {
							transitionsComplete(transitionDirection);
							return;
						}
						_initTransitionQueue(transitionDirection);
					}
				}
			}
		}

		private function _registerComponentTransition(transitionDirection : String,componentToRegister : IPageComponent) : void {
			//trace('reg comp transition: dir: ' + transitionDirection + ' page: ' + componentToRegister + ' level: ' + componentToRegister.getLevel());
			var level : int = componentToRegister.getLevel();
			var id : String = componentToRegister.getComponentID();
			
			
			if (componentTransitions[transitionDirection] == null)componentTransitions[transitionDirection] = new Dictionary();
			if (componentTransitions[transitionDirection][level] == null) {
				componentTransitions[transitionDirection][level] = new Dictionary();
			}
			if (componentTransitions[transitionDirection][level][id] == null) {
				componentTransitions[transitionDirection][level][id] = componentToRegister;
				componentTransitionsRemaining[transitionDirection]++;
			}
			if (minComponentChangeLevel[transitionDirection] == -1 || level < minComponentChangeLevel[transitionDirection])minComponentChangeLevel[transitionDirection] = level;
			if (level > maxComponentChangeLevel[transitionDirection])maxComponentChangeLevel[transitionDirection] = level;
		}

		private function _removeComponentTransition(transitionDirection : String,componentToRemove : IPageComponent) : void {
			//trace('remove comp transition: dir: ' + transitionDirection + ' page: ' + componentToRemove + ' level: ' + componentToRemove.getLevel());
			var level : int = componentToRemove.getLevel();
			var id : String = componentToRemove.getComponentID();
			if (componentTransitions[transitionDirection][level] == null)return;
			if (componentTransitions[transitionDirection][level][id] != null) {
				delete componentTransitions[transitionDirection][level][id];
				if (!DictionaryUtil.dictionaryHasItems(componentTransitions[transitionDirection][level])) {
					delete componentTransitions[transitionDirection][level];
					if (!DictionaryUtil.dictionaryHasItems(componentTransitions[transitionDirection])) {
						delete (componentTransitions[transitionDirection]);
					}
					componentTransitionsRemaining[transitionDirection]--;
					if (transitionsRemaining[transitionDirection] == 0 && componentTransitionsRemaining[transitionDirection] == 0) {
						transitionsComplete(transitionDirection);
						return;
					}
					_initTransitionQueue(transitionDirection);
				}
			}
		}

		protected static function getInstance() : TransitionManager {
			if (instance == null)instance = new TransitionManager();
			return instance;
		}

		public static function getPageTransitionsRemaining(transitionDirection : String) : int {
			return getInstance().transitionsRemaining[transitionDirection];
		}

		private static function getComponentTransitionsRemaining(transitionDirection : String) : int {
			return getInstance().componentTransitionsRemaining[transitionDirection];
		}
	}
}

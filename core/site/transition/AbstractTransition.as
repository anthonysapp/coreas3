package core.site.transition {
	import core.site.interfaces.ITransition;

	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	/**
	 * @author anthonysapp
	 */
	public class AbstractTransition extends EventDispatcher implements ITransition {
		public function AbstractTransition(target : IEventDispatcher = null) {
			super(target);
		}
		/**
		 * Implement ITransition
		 */
		public function beforeLoadPage() : void {
		}

		public function loadPage() : void {
		}

		public function afterLoadPage() : void {
		}

		public function beforeTransitionIn() : void {
		}

		public function transitionIn() : void {
		}

		public function afterTransitionIn() : void {
		}

		public function beforeTransitionOut() : void {
		}

		public function transitionOut() : void {
		}

		public function afterTransitionOut() : void {
		}

		public function pageChangeComplete() : void {
		}
		
		public function afterAllTransitions() : void {
		}
	}
}

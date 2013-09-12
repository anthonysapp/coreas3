package core.site.transition {
	import core.site.SiteFacade;

	import flash.events.IEventDispatcher;

	/**
	 * @author anthonysapp
	 */
	public class LoadOutInTransition extends AbstractTransition {
		public function LoadOutInTransition(target : IEventDispatcher = null) {
			super(target);
		}

		override public function beforeLoadPage() : void {
			SiteFacade.getInstance().loadPage();
		}

		override public function afterLoadPage() : void {
			TransitionManager.doTransitions(TransitionManager.TRANSITION_OUT);
		}

		override public function afterTransitionOut() : void {
			TransitionManager.doTransitions(TransitionManager.TRANSITION_IN);
		}

		override public function afterTransitionIn() : void {
			SiteFacade.getInstance().pageChangeComplete();
			SiteFacade.getInstance().afterPageChange();
		}
	}
}

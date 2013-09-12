package core.site.transition {
	import core.site.SiteFacade;
	import flash.events.IEventDispatcher;

	/**
	 * @author anthonysapp
	 */
	public class NormalTransition extends AbstractTransition {
		public function NormalTransition(target : IEventDispatcher = null) {
			super(target);
		}
		override public function beforeLoadPage() : void {
			TransitionManager.doTransitions(TransitionManager.TRANSITION_OUT);
		}
		override public function afterLoadPage():void{
			TransitionManager.doTransitions(TransitionManager.TRANSITION_IN);
		}
		override public function afterTransitionIn():void{
			SiteFacade.getInstance().pageChangeComplete();
			SiteFacade.getInstance().afterPageChange();
		}
		override public function afterTransitionOut():void{
			SiteFacade.getInstance().loadPage();
		}
	}
}

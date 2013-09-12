package core.site.transition {
	import core.site.SiteFacade;

	import flash.events.IEventDispatcher;

	/**
	 * @author anthonysapp
	 */
	public class LoadInAndOutTransition extends AbstractTransition {
		private var inTransitionsDone:Boolean = false;
		private var outTransitionsDone:Boolean = false;
		
		public function LoadInAndOutTransition(target : IEventDispatcher = null) {
			super(target);
		}
		
		override public function beforeLoadPage() : void {
			SiteFacade.getInstance().loadPage();
		}
		override public function afterTransitionIn():void{
			inTransitionsDone = true;
			checkAllDone();
		}
		override public function afterTransitionOut():void{
			outTransitionsDone = true;
			checkAllDone();
		}
		override public function afterLoadPage() : void {
			TransitionManager.doTransitions(TransitionManager.TRANSITION_IN);
			TransitionManager.doTransitions(TransitionManager.TRANSITION_OUT);
		}

		override public function afterAllTransitions() : void {
			SiteFacade.getInstance().pageChangeComplete();
			SiteFacade.getInstance().afterPageChange();
		}
		private function checkAllDone() : void {
			if (inTransitionsDone && outTransitionsDone) SiteFacade.getInstance().afterAllTransitions();
		}
	}
}

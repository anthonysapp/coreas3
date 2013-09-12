package core.site.transition {
	import core.site.SiteFacade;
	import core.site.interfaces.IPage;
	import core.site.interfaces.ITransitionActiveHandler;

	/**
	 * @author anthonysapp
	 */
	public class AbstractTransitionActiveHandler implements ITransitionActiveHandler {
		protected var facade : SiteFacade;

		public function AbstractTransitionActiveHandler() {
			facade = SiteFacade.getInstance();
		}

		public function isPageActiveForInTransition(page : IPage) : Boolean {
			return false;
		}

		public function isPageActiveForOutTransition(page : IPage) : Boolean {
			return false;
		}
	}
}

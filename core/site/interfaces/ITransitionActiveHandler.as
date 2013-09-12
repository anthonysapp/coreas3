package core.site.interfaces {

	/**
	 * @author anthonysapp
	 */
	public interface ITransitionActiveHandler {
		function isPageActiveForInTransition(page:IPage):Boolean;		function isPageActiveForOutTransition(page:IPage):Boolean;
	}
}

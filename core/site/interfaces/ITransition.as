package core.site.interfaces {

	/**
	 * @author anthonysapp
	 */
	public interface ITransition {
		function beforeLoadPage():void;
		function loadPage():void;
		function afterLoadPage():void;
		function beforeTransitionIn():void;
		function transitionIn():void;
		function afterTransitionIn():void;
		function beforeTransitionOut():void;
		function transitionOut():void;
		function afterTransitionOut():void;
		function afterAllTransitions():void;
		function pageChangeComplete():void;
	}
}

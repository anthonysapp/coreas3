package core.site2.view.components {
	import core.interfaces.IRegisterable;

	/**
	 * @author anthonysapp
	 */
	public interface IPageViewComponent extends IRegisterable {
		
		function transitionIn() : void;

		function transitionOut() : void;

		function transitionInComplete() : void;
		function transitionOutComplete() : void;	}
}

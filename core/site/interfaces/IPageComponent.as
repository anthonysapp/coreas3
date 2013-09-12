package core.site.interfaces {
	import core.interfaces.IRegisterable;

	/**
	 * @author anthonysapp
	 */
	public interface IPageComponent extends IRegisterable {
		function transitionIn() : void;

		function transitionOut() : void;

		function transitionInComplete() : void;

		function transitionOutComplete() : void;

		//
		function setPageID(value : String) : void;

		function getPageID() : String;

		function getComponentID() : String;

		function getBaseURL() : String;

		//

		function getContainer() : String;

		function setContainer(containerName : String) : void;

		//
		function setData(data : Object) : void;

		function onDataChange() : void;
		
		function onLanguageChange() : void;

		function getData() : Object;

		function populate() : void;

		//
		function onBeforePageChange() : void;

		function onPageChangeStart() : void;

		function onPageChangeComplete() : void;

		function onAfterPageChange() : void;

		function setLevel(value : int) : void;

		function getLevel() : int;
	}
}

package core.site.interfaces {
	import org.puremvc.as3.interfaces.IMediator;

	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;

	import core.interfaces.IRegisterable;

	/**
	 * @author anthonysapp
	 */
	public interface IPage extends IRegisterable {
		function transitionIn() : void;

		function transitionOut() : void;

		function transitionInComplete() : void;
		function transitionOutComplete() : void;

		//
		function setTransitionType(value : String) : void;

		function getTransitionType() : String;

		//
		function setActiveType(value : String) : void;

		function getActiveType() : String;

		//
		function setPageID(value : String) : void;

		function getPageID() : String;

		function getBaseURL() : String;

		
		function getPageName() : String;

		//
		function setLevel(value : int) : void;

		function getLevel() : int;

		//
		function setParent(parent : DisplayObjectContainer) : void;

		function getParent() : DisplayObjectContainer;

		function getPageContainer() : String;

		function setPageContainer(containerName : String) : void;

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

		//

		function addChild(child : DisplayObject) : DisplayObject;
		function removeChild(child : DisplayObject) : DisplayObject;

		function getPageMediator() : Class;
	}
}

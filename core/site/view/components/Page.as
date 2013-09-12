package core.site.view.components {
	import core.site.view.mediators.PageMediator;
	import flash.display.DisplayObjectContainer;

	import core.site.transition.ActiveType;

	import nl.demonsters.debugger.MonsterDebugger;

	import core.site.transition.TransitionManager;
	import core.site.transition.TransitionType;
	import core.site.SiteFacade;
	import core.display.StateClip;
	import core.site.interfaces.IPage;

	/**
	 * @author anthonysapp
	 */
	public class Page extends StateClip implements IPage {
		protected var id:String;
		//
		protected var siteFacade : SiteFacade = SiteFacade.getInstance();
		protected var level : int = -1;
		protected var transitionType : String = TransitionType.NORMAL;
		protected var activeType : String = ActiveType.NORMAL;
		protected var parentPage : DisplayObjectContainer;
		protected var pageContainerName : String;
		protected var mediatorName:String;
		
		public var data : Object;
		
		public function Page() {
			super();
		}

		override protected function init() : void {
			siteFacade.startup(true, false);
			siteFacade.addPage(this);
		}

		override public function destroy() : void {
		}

		public function setData(value : Object) : void {
			data = value;
			MonsterDebugger.trace(this, data);
		}

		public function getData() : Object {
			return this.data;
		}

		public function onDataChange() : void {
		}

		public function onLanguageChange() : void {
		}

		/**
		 * should contain only logic to fill the page's elements with data
		 */
		public function populate() : void {
			MonsterDebugger.trace(this, 'populate');
		}

		/**
		 * should contain only logic to transition elements of the page in
		 */
		public function transitionIn() : void {
			transitionInComplete();
		}

		/**
		 * should contain only logic to transition elements of the page out
		 */
		public function transitionOut() : void {
			transitionOutComplete();
		}

		public function transitionInComplete() : void {
			TransitionManager.removePageTransition(TransitionManager.TRANSITION_IN, this);
		}

		public function transitionOutComplete() : void {
			SiteFacade.getInstance().removePage(this);
			TransitionManager.removePageTransition(TransitionManager.TRANSITION_OUT, this);
		}

		public function onBeforePageChange() : void {
			MonsterDebugger.trace(this, 'before page change');
		}

		public function onPageChangeStart() : void {
			MonsterDebugger.trace(this, 'page change start');
		}

		public function onPageChangeComplete() : void {
			MonsterDebugger.trace(this, 'page change complete');
		}

		public function onAfterPageChange() : void {
			MonsterDebugger.trace(this, 'after page change');
		}

		public function onRegister() : void {
		}

		public function onRemove() : void {
		}

		public function update() : void {
		}
		public function setPageID(value:String):void{
			id = value;
		}
		public function getPageID() : String {
			return id == null ? 'site' : id;
		}

		public function setLevel(value : int) : void {
			level = value;
		}

		public function getLevel() : int {
			return level;
		}

		public function getBaseURL() : String {
			return '';
		}
		public function changeTransitionType(value:String):void {
			siteFacade.setPageTransitionType(getPageID(),value);
			setTransitionType(value);
		}

		public function setTransitionType(value : String) : void {
			transitionType = value;
		}

		public function getTransitionType() : String {
			return transitionType;
		}

		public function setActiveType(value : String) : void {
			activeType = value;
		}

		public function getActiveType() : String {
			return activeType;
		}

		public function setParent(parentPage : DisplayObjectContainer) : void {
			this.parentPage = parentPage;
		}

		public function getParent() : DisplayObjectContainer {
			return parentPage;
		}

		public function getPageName() : String {
			return data.name;
		}

		public function setPageContainer(containerName : String) : void {
			pageContainerName = containerName;
		}

		public function getPageContainer() : String {
			return pageContainerName;
		}
		public function getMediatorName():String{
			return getPageID() + 'Mediator';
		}
		public function getPageMediator():Class{
			return PageMediator;
		}
	}
}

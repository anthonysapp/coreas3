package core.site.view.components {
	import core.site.SiteFacade;
	import core.site.transition.TransitionManager;
	import core.site.interfaces.IPageComponent;
	import core.display.StateClip;

	/**
	 * @author anthonysapp
	 */
	public class PageComponent extends StateClip implements IPageComponent {
		protected var facade : SiteFacade = SiteFacade.getInstance();
		protected var data : Object;
		protected var pageID : String;
		protected var container : String;
		protected var level : int = 0;

		public function PageComponent() {
			super();
		}

		override protected function init() : void {
			facade.startup(true, false);
			facade.addPageComponent(this);
		}

		public function onRegister() : void {
		}

		public function setData(value : Object) : void {
			data = value;
		}

		public function getData() : Object {
			return this.data;
		}

		
		public function transitionIn() : void {
			transitionInComplete();
		}

		public function transitionOut() : void {
			transitionOutComplete();
		}

		public function transitionInComplete() : void {
			TransitionManager.removeComponentTransition(TransitionManager.TRANSITION_IN, this);
		}

		public function transitionOutComplete() : void {
			SiteFacade.getInstance().removePageComponent(this);
			TransitionManager.removeComponentTransition(TransitionManager.TRANSITION_OUT, this);
			destroy();
		}

		public function setPageID(value : String) : void {
			pageID = value;
		}

		public function getPageID() : String {
			return pageID == null ? 'site' : pageID;
		}

		public function getComponentID() : String {
			return 'nav';
		}

		public function getBaseURL() : String {
			return '';
		}

		
		public function getContainer() : String {
			return container;
		}

		public function setContainer(containerName : String) : void {
			container = containerName;
		}

		public function onDataChange() : void {
		}

		public function onLanguageChange() : void {
		}

		public function populate() : void {
		}

		public function onBeforePageChange() : void {
		}

		public function onPageChangeStart() : void {
		}

		public function onPageChangeComplete() : void {
		}

		public function onAfterPageChange() : void {
		}

		public function onRemove() : void {
		}

		public function update() : void {
		}

		public function setLevel(value : int) : void {
			level = value;
		}

		public function getLevel() : int {
			return level;
		}
	}
}

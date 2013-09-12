package core.site.view.mediators {
	import core.site.model.PageVO;
	import core.site.transition.TransitionManager;

	import org.puremvc.as3.interfaces.INotification;

	import core.site.SiteFacade;
	import core.site.model.PageComponentProxy;
	import core.site.model.PageComponentVO;
	import core.site.model.SiteVO;
	import core.site.interfaces.IPageComponent;

	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * @author anthonysapp
	 */
	public class PageComponentMediator extends Mediator {
		private var pageComponentProxy : PageComponentProxy;
		private var siteData : SiteVO;
		private var componentData : PageComponentVO;

		public function PageComponentMediator(mediatorName : String = null, viewComponent : Object = null) {
			super(mediatorName, viewComponent);
		}

		override public function onRegister() : void {
			pageComponentProxy = facade.retrieveProxy(component.getPageID()+ component.getComponentID() + 'Proxy') as PageComponentProxy;
			component.onRegister();
			setSiteData();
			setComponentLevel();
			setComponentData();
			component.onDataChange();
			component.populate();
		}

		private function setComponentLevel() : void {
			var pvo : PageVO = siteData.idMap[component.getPageID()];
			component.setLevel(pvo.level);
		}

		private function setSiteData() : void {
			siteData = facade.retrieveProxy('SiteProxy').getData() as SiteVO;
		}

		private function setComponentData() : void {
			var newData:Object = siteData.idMap[component.getPageID()].components.(@id == component.getComponentID());
			pageComponentProxy.setData(newData);
			componentData = pageComponentProxy.getData() as PageComponentVO;
			component.setData(componentData);
		}

		override public function handleNotification( note : INotification ) : void {
			switch (note.getName()) {
				case SiteFacade.AFTER_DATA_CHANGE:
					setSiteData();
					setComponentData();
					component.onDataChange();
					break;
				case SiteFacade.AFTER_LANGUAGE_CHANGE:
					component.onLanguageChange();
					break;
				case SiteFacade.BEFORE_PAGE_CHANGE:
					component.onBeforePageChange();
					break;
				case SiteFacade.PAGE_CHANGE_START:
					component.onPageChangeStart();
					break;
				case SiteFacade.PAGE_CHANGE_COMPLETE:
					component.onPageChangeComplete();
					break;
				case SiteFacade.AFTER_PAGE_CHANGE:
					component.onAfterPageChange();
					break;
				case SiteFacade.BEFORE_TRANSITION_IN:
					if (getPageMediator() == null || getPageMediator().getTransitionActiveHandler().isPageActiveForInTransition(getPageMediator().page)) {
						TransitionManager.registerComponentTransition(TransitionManager.TRANSITION_IN, component);
					}
					break;
				case SiteFacade.BEFORE_TRANSITION_OUT:
					if (getPageMediator() == null)return;
					if (getPageMediator().getTransitionActiveHandler().isPageActiveForOutTransition(getPageMediator().page)) {
						TransitionManager.registerComponentTransition(TransitionManager.TRANSITION_OUT, component);
					}
					break;
			}
		}

		private function getPageMediator() : PageMediator {
			return (SiteFacade.getInstance().retrieveMediator(component.getPageID() + 'Mediator') as PageMediator);
		}

		override public function listNotificationInterests() : Array {
			return [SiteFacade.DATA_CHANGE,
					SiteFacade.AFTER_LANGUAGE_CHANGE,
					SiteFacade.BEFORE_PAGE_CHANGE,
					SiteFacade.PAGE_CHANGE_START,
					SiteFacade.PAGE_CHANGE_COMPLETE,
                    SiteFacade.AFTER_PAGE_CHANGE,
                    SiteFacade.AFTER_LOAD_PAGE,
                    SiteFacade.BEFORE_TRANSITION_IN,
                    SiteFacade.BEFORE_TRANSITION_OUT,
                    SiteFacade.AFTER_ALL_TRANSITIONS];
		}

		public function get component() : IPageComponent {
			return viewComponent as IPageComponent;
		}
	}
}

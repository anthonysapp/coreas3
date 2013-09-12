package core.site.view.mediators {
	import core.site.view.components.PageComponent;
	import core.q.File;

	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;

	import core.q.QLibrary;
	import core.site.transition.CustomTransitionActiveHandler;
	import core.site.transition.NormalTransitionActiveHandler;
	import core.site.transition.ActiveType;
	import core.site.interfaces.ITransitionActiveHandler;
	import core.site.model.SiteVO;
	import core.site.model.PageVO;
	import core.site.transition.TransitionManager;
	import core.site.model.PageProxy;

	import org.puremvc.as3.interfaces.INotification;

	import core.site.SiteFacade;
	import core.site.model.SiteProxy;
	import core.site.interfaces.IPage;

	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * @author anthonysapp
	 */
	public class PageMediator extends Mediator {
		private var pageProxy : PageProxy;
		private var siteData : SiteVO;
		private var pageData : PageVO;
		private var transitionActiveHandler : ITransitionActiveHandler;

		public function PageMediator(mediatorName : String = null, viewComponent : Object = null) {
			super(mediatorName, viewComponent);
		}

		override public function onRegister() : void {
			pageProxy = facade.retrieveProxy(page.getPageID() + 'Proxy') as PageProxy;
			page.onRegister();
			setSiteData();
			setPageData();
			setPageTransitionType();
			setPageActiveType();
		}

		private function addPageComponents() : void {
			for each (var cxml:XML in pageData.components) {
				addPageComponent(cxml);
			}
		}

		private function addPageComponent(cxml : XML) : void {
			var cID : String = cxml.@id.toString();
			var cFile : File = QLibrary.getFileById(cID);
			if (cFile == null)return;
			var cAsset : DisplayObject = cFile.asset as DisplayObject;
			if (cAsset == null)return;
			var cContainerName : String = cxml.@container.toString();
			var cContainer : DisplayObjectContainer; 
			(cAsset as PageComponent).setPageID(cxml.@parent);
			if (cContainerName == '') {
				page.addChild(cAsset);
			} else {
				cContainer = (page as DisplayObjectContainer).getChildByName(cContainerName) as DisplayObjectContainer;
				if (cContainer == null) {
					page.addChild(cAsset);
				} else {
					cContainer.addChild(cAsset);
				}
			}
		}

		private function setSiteData() : void {
			siteData = facade.retrieveProxy('SiteProxy').getData() as SiteVO;
		}

		private function setPageTransitionType() : void {
			page.setTransitionType(pageData.transition);
		}

		private function setPageActiveType() : void {
			page.setTransitionType(pageData.active);
		}

		override public function listNotificationInterests() : Array {
			return [SiteFacade.DATA_CHANGE,
					SiteFacade.AFTER_LANGUAGE_CHANGE,
					SiteFacade.BEFORE_PAGE_CHANGE,
					SiteFacade.PAGE_CHANGE_START,
					SiteFacade.PAGE_CHANGE_COMPLETE,
                    SiteFacade.AFTER_PAGE_CHANGE,
                    SiteFacade.LOAD_PAGE_COMPLETE,
                    SiteFacade.AFTER_LOAD_PAGE,
                    SiteFacade.BEFORE_TRANSITION_IN,
                    SiteFacade.BEFORE_TRANSITION_OUT,
                    SiteFacade.AFTER_ALL_TRANSITIONS];
		}

		private function getPageData() : Object {
			pageData = siteData.idMap[this.page.getPageID()];
			return pageData;
		}

		private function setPageData() : void {
			pageProxy.setData(getPageData());
			page.setData(pageData);
			page.onDataChange();
			page.populate();
		}

		override public function handleNotification( note : INotification ) : void {
			switch (note.getName()) {
				case SiteFacade.DATA_CHANGE:
					setSiteData();
					setPageData();
					page.onDataChange();
					break;
				case SiteFacade.AFTER_LANGUAGE_CHANGE:
					page.onLanguageChange();
					break;
				case SiteFacade.BEFORE_PAGE_CHANGE:
					page.onBeforePageChange();
					break;
				case SiteFacade.PAGE_CHANGE_START:
					page.onPageChangeStart();
					break;
				case SiteFacade.PAGE_CHANGE_COMPLETE:
					page.onPageChangeComplete();
					break;
				case SiteFacade.LOAD_PAGE_COMPLETE:
					addPageComponents();
					break;
				case SiteFacade.AFTER_PAGE_CHANGE:
					page.onAfterPageChange();
					break;
				case SiteFacade.BEFORE_TRANSITION_IN:
					if (getTransitionActiveHandler().isPageActiveForInTransition(page)) {
						TransitionManager.registerPageTransition(TransitionManager.TRANSITION_IN, page);
					}
					break;
				case SiteFacade.BEFORE_TRANSITION_OUT:
					if (getTransitionActiveHandler().isPageActiveForOutTransition(page)) {
						TransitionManager.registerPageTransition(TransitionManager.TRANSITION_OUT, page);
					}
					break;
				case SiteFacade.AFTER_LOAD_PAGE:
					break;
			}
		}

		public function getTransitionActiveHandler() : ITransitionActiveHandler {
			if (transitionActiveHandler == null) {
				switch (page.getActiveType()) {
					case ActiveType.CUSTOM:
						transitionActiveHandler = new CustomTransitionActiveHandler();
						break;
					case ActiveType.NORMAL:
					default:
						transitionActiveHandler = new NormalTransitionActiveHandler();
						break;
				}
			}
			return transitionActiveHandler;
		}

		public function get page() : IPage {
			return viewComponent as IPage;
		}
	}
}

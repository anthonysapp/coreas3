package core.site {
	import flash.utils.Dictionary;

	import core.site.model.SiteVO;
	import core.site.controllers.PrepPageComponentCommand;
	import core.site.interfaces.IPageComponent;
	import core.site.view.mediators.LanguageMediator;
	import core.site.controllers.SetLanguageCommand;
	import core.site.model.PageVO;
	import core.site.transition.LoadOutInTransition;
	import core.site.transition.LoadInOutTransition;
	import core.site.transition.LoadInAndOutTransition;
	import core.site.transition.TransitionType;
	import core.site.transition.NormalTransition;
	import core.site.interfaces.ITransition;

	import com.asual.swfaddress.SWFAddress;

	import core.site.view.mediators.SiteMediator;
	import core.site.controllers.PrepPageCommand;
	import core.site.controllers.StartupCommand;
	import core.site.interfaces.IPage;

	import org.puremvc.as3.patterns.facade.Facade;

	/**
	 * @author anthonysapp
	 */
	public class SiteFacade extends Facade {
		public static const LOAD_DATA : String = 'loadData';
		public static const DATA_LOADED : String = "dataLoaded";
		public static const DATA_CHANGE : String = "dataChange";
		public static const AFTER_DATA_CHANGE : String = "afterDataChange";
		//
		public static const STARTUP : String = "startup";
		public static const SET_PAGE_BY_ID : String = "setPageByID";
		public static const SET_PAGE_BY_NAME : String = "setPageByName";
		//
		public static const BEFORE_PAGE_REFRESH : String = "beforePageRefresh";
		public static const PAGE_REFRESH : String = "pageRefresh";
		public static const AFTER_PAGE_REFRESH : String = "afterPageRefresh";
		//
		public static const SET_LANGUAGE : String = "setLanguage";
		public static const BEFORE_LANGUAGE_CHANGE : String = "beforeLanguageChange";
		public static const LANGUAGE_CHANGE : String = "languageChange";
		public static const AFTER_LANGUAGE_CHANGE : String = "afterLanguageChange";
		//
		public static const BEFORE_PAGE_ADDED : String = "beforePageAdded";
		public static const PAGE_ADDED : String = "pageAdded";
		public static const BEFORE_PAGE_REMOVED : String = "beforePageRemoved"; 
		public static const PAGE_REMOVED : String = "pageRemoved"; 
		//
		public static const BEFORE_PAGE_CHANGE : String = "beforePageChange";
		public static const PAGE_CHANGE_START : String = "pageChangeStart";
		public static const PAGE_CHANGE_COMPLETE : String = "pageChangeComplete";
		public static const AFTER_PAGE_CHANGE : String = "afterPageChange";
		//site flow / transitions
		public static const SET_TRANSITION_TYPE : String = "setTransitionType";
		public static const BEFORE_LOAD_PAGE : String = "beforeLoadPage";
		public static const LOAD_PAGE : String = "loadPage";
		public static const LOAD_PAGE_PROGRESS : String = "loadPageProgress";
		public static const LOAD_PAGE_COMPLETE : String = "loadPageComplete";
		public static const AFTER_LOAD_PAGE : String = "afterLoadPage";
		public static const BEFORE_TRANSITION_IN : String = "beforeTransitionIn";		public static const TRANSITION_IN : String = "transitionIn";
		public static const AFTER_TRANSITION_IN : String = "afterTransitionIn";
		public static const BEFORE_TRANSITION_OUT : String = "beforeTransitionOut";
		public static const TRANSITION_OUT : String = "transitionOut";
		public static const AFTER_TRANSITION_OUT : String = "afterTransitionOut";	
		public static const AFTER_ALL_TRANSITIONS : String = "afterAllTransitions";	
		//page components
		public static const BEFORE_PAGE_COMPONENT_ADDED : String = "beforePageCompoenentAdded";		public static const PAGE_COMPONENT_ADDED : String = "pageCompoenentAdded";
		public static const PAGE_COMPONENT_REMOVED : String = "pageComponentRemoved";		//
		private var started : Boolean = false;
		private var useSWFAddress : Boolean = true;
		private var dataURL : String = 'assets/xml/site.xml';
		private var language : String = 'en';
		
		private var languageIsFirstElement : Boolean;
		public var extras : Object = new Object();

		
		public static function getInstance() : SiteFacade {
			if (instance == null) instance = new SiteFacade();
			return instance as SiteFacade;
		}

		override protected function initializeController() : void {
			super.initializeController();
			
			registerCommand(STARTUP, StartupCommand); 
			registerCommand(SET_LANGUAGE, SetLanguageCommand);
			registerCommand(PAGE_ADDED, PrepPageCommand);
			registerCommand(PAGE_COMPONENT_ADDED, PrepPageComponentCommand);
		}

		public function startup(useSWFAddress : Boolean = true, languageIsFirstElement : Boolean = false) : void {
			if (started)return;
			started = true;
			this.useSWFAddress = useSWFAddress && !languageIsFirstElement;
			this.languageIsFirstElement = languageIsFirstElement;
			
			sendNotification(STARTUP);
		}

		public function getLanguageIsFirstElement() : Boolean {
			return languageIsFirstElement;
		}

		public function loadData(data : Object = null) : void {
			sendNotification(LOAD_DATA, data);
		}

		public function dataLoaded(data : XML) : void {
			sendNotification(DATA_LOADED, data);
		}

		public function addPage(pageToAdd : IPage) : void {
			sendNotification(BEFORE_PAGE_ADDED, pageToAdd);
		}

		public function addPageComponent(componentToAdd : IPageComponent) : void {
			sendNotification(BEFORE_PAGE_COMPONENT_ADDED, componentToAdd);
		}

		public function componentAdded(addedComponent : IPageComponent) : void {
			sendNotification(PAGE_COMPONENT_ADDED, addedComponent);
		}

		public function pageAdded(addedPage : IPage) : void {
			sendNotification(PAGE_ADDED, addedPage);
		}

		public function removePage(pageToRemove : IPage) : void {
			sendNotification(PAGE_REMOVED, pageToRemove);
		}

		public function removePageComponent(pageComponentToRemove : IPageComponent) : void {
			sendNotification(PAGE_COMPONENT_REMOVED, pageComponentToRemove);
		}

		public function beforePageChange() : void {
			sendNotification(BEFORE_PAGE_CHANGE);
		}

		public function pageChangeStart() : void {
			sendNotification(PAGE_CHANGE_START);
		}

		public function pageChangeComplete() : void {
			sendNotification(PAGE_CHANGE_COMPLETE);
		}

		public function afterPageChange() : void {
			sendNotification(AFTER_PAGE_CHANGE);
		}

		/**
		 * page flow notifications
		 */
		public function setTransitionType(transitionType : String = TransitionType.NORMAL) : void {
			var aTransition : ITransition;
			switch (transitionType) {
				case TransitionType.LOAD_OUT_IN:
					aTransition = new LoadOutInTransition();
					break;
				case TransitionType.LOAD_IN_OUT:
					aTransition = new LoadInOutTransition();
					break;
				case TransitionType.LOAD_IN_AND_OUT:
					aTransition = new LoadInAndOutTransition();
					break;
				case TransitionType.NORMAL:
				default:
					aTransition = new NormalTransition();
					break;
			}
			sendNotification(SET_TRANSITION_TYPE, aTransition);
		}

		public function beforeLoadPage() : void {
			sendNotification(BEFORE_LOAD_PAGE);
		}

		public function loadPage() : void {
			sendNotification(LOAD_PAGE);
		}

		public function afterLoadPage() : void {
			sendNotification(AFTER_LOAD_PAGE);
		}

		public function loadPageComplete() : void {
			sendNotification(LOAD_PAGE_COMPLETE);
		}

		public function beforeTransitionIn() : void {
			sendNotification(BEFORE_TRANSITION_IN);
		}

		public function transitionIn() : void {
			sendNotification(TRANSITION_IN);
		}

		public function afterTransitionIn() : void {
			sendNotification(AFTER_TRANSITION_IN);
		}

		public function beforeTransitionOut() : void {
			sendNotification(BEFORE_TRANSITION_OUT);
		}

		public function transitionOut() : void {
			sendNotification(TRANSITION_OUT);
		}

		public function afterTransitionOut() : void {
			sendNotification(AFTER_TRANSITION_OUT);
		}

		public function afterAllTransitions() : void {
			sendNotification(AFTER_ALL_TRANSITIONS);
		}

		public function getActivePages() : Dictionary {
			return (retrieveMediator(SiteMediator.NAME) as SiteMediator).getActivePages();
		}

		public function getPageChangeLevel() : int {
			return (retrieveMediator(SiteMediator.NAME) as SiteMediator).getPageChangeLevel();
		}

		public function setPage(pageName : String) : void {
			getInstance().sendNotification(SET_PAGE_BY_NAME, pageName);
		}

		public function setPageByID(pageID : String) : void {
			getInstance().sendNotification(SET_PAGE_BY_ID, pageID);
		}

		protected static function getSiteData() : SiteVO {
			return getInstance().retrieveProxy('SiteProxy').getData() as SiteVO;
		}

		public function getLastPageID() : String {
			return (retrieveMediator(SiteMediator.NAME) as SiteMediator).getLastPageID();
		}

		public function getLastPageName() : String {
			return (retrieveMediator(SiteMediator.NAME) as SiteMediator).getLastPageName();
		}

		public function getLastPageArray() : Array {
			return (retrieveMediator(SiteMediator.NAME) as SiteMediator).getLastPageArray();
		}

		public function getNewPageID() : String {
			return (retrieveMediator(SiteMediator.NAME) as SiteMediator).getNewPageID();
		}

		public function getNewPageName() : String {
			return (retrieveMediator(SiteMediator.NAME) as SiteMediator).getNewPageName();
		}

		public function getNewPageArray() : Array {
			return (retrieveMediator(SiteMediator.NAME) as SiteMediator).getNewPageArray();
		}

		public function getPageID() : String {
			return (retrieveMediator(SiteMediator.NAME) as SiteMediator).getPageID();
		}

		public function getPageName() : String {
			return (retrieveMediator(SiteMediator.NAME) as SiteMediator).getPageName();
		}

		public function getPageArray() : Array {
			return (retrieveMediator(SiteMediator.NAME) as SiteMediator).getPageArray();
		}

		public function getTransitionArray() : Array {
			return (retrieveMediator(SiteMediator.NAME) as SiteMediator).getTransitionArray();
		}

		public function getLastTransitionArray() : Array {
			return (retrieveMediator(SiteMediator.NAME) as SiteMediator).getLastTransitionArray();
		}

		public function setDataURL(dataURL : String) : void {
			this.dataURL = dataURL;
		}

		public function getDataURL() : String {
			return hasMediator('LanguageMediator') ? (retrieveMediator('LanguageMediator') as LanguageMediator).getDataURL() : dataURL  ;
		}

		public function setLanguage(language : String, refreshPage : Boolean = true) : void {
			this.language = language;
			sendNotification(SET_LANGUAGE, {language:language, refreshPage:refreshPage});
		}

		public function refreshPage(clearLoadedPages : Boolean = false) : void {
			sendNotification(BEFORE_PAGE_REFRESH, clearLoadedPages);
		}

		public function getLanguage() : String {
			return language;
		}
		public function beforeLanguageChange() : void {
			sendNotification(BEFORE_LANGUAGE_CHANGE);
		}
		public function getExtras():Object{
			return getInstance().extras;
		}

		public function setPageTransitionType(pageID : String, value : String) : void {
			(retrieveMediator(SiteMediator.NAME) as SiteMediator).setPageTransitionType(pageID, value);
		}
	}
}

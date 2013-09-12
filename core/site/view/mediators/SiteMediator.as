package core.site.view.mediators {
	import core.site.model.SiteAssetVO;

	import com.adobe.utils.DictionaryUtil;

	import flash.utils.Dictionary;

	import core.site.interfaces.IPageComponent;

	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;

	import core.q.QLibrary;

	import nl.demonsters.debugger.MonsterDebugger;

	import core.site.model.PageVO;
	import core.site.model.SiteVO;

	import com.asual.swfaddress.SWFAddressEvent;
	import com.asual.swfaddress.SWFAddress;

	import core.q.File;
	import core.q.events.QEvent;
	import core.q.QLoader;
	import core.site.model.SiteProxy;
	import core.site.interfaces.IPage;

	import org.puremvc.as3.interfaces.INotification;

	import core.site.SiteFacade;

	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * @author anthonysapp
	 */
	public class SiteMediator extends Mediator {
		public static const NAME : String = "SiteMediator";
		public static const DEFAULT_PAGE_ID : String = "home";
		public static const SUPPORTED_LANGUAGES : Array = ['en', 'fr'];
		//
		private var siteProxy : SiteProxy;
		private var siteTitle : String;
		//
		protected var baseURL : String;
		protected var pageLoader : QLoader;
		protected var defaultPage : String;
		protected var newPageVO : PageVO;
		protected var newPage : String;
		protected var newPageArray : Array;
		protected var currentPage : String;
		protected var currentPageArray : Array;
		protected var lastPage : String;
		protected var lastPageArray : Array;
		protected var transitionArray : Array = null;
		protected var lastTransitionArray : Array = null;
		protected var storedPage : String;
		//
		protected var activePages : Dictionary;
		protected var numActivePages : int = 0;
		protected var pageIsChanging : Boolean = false;
		protected var pageChangeLevel : int = 0;
		//
		protected var filesToLoad : Array;
		protected var firstLoad : Boolean = true;
		protected var filesLoaded : Dictionary = new Dictionary();
		protected var siteData : SiteVO;
		protected var isRefreshing : Boolean = false;
		// 
		protected var languageIsFirstElement : Boolean = true;
		private var dataPage : Object;
		private var testingPageComponent : Boolean = false;
		private var changeLanguageWithPageLoad : Boolean = false;

		//
		public function SiteMediator() {
			super(NAME);
			facade = SiteFacade.getInstance();
		}

		override public function onRegister() : void {
			siteProxy = facade.retrieveProxy(SiteProxy.NAME) as SiteProxy;
			siteTitle = SWFAddress.getTitle();
			activePages = new Dictionary();
		}

		/**
		 * handler for when there's a page change
		 */
		private function onSWFAddressChange(event : SWFAddressEvent = null) : void {
			if (pageIsChanging) {
				storedPage = SWFAddress.getValue();
				return;
			}
			pageIsChanging = true;
			if (dataPage) {
				loadData(dataPage);
				return;
			}
			var val : String = SWFAddress.getValue();
			var pArr : Array = val.split('/');
			if (pArr[0] == '')pArr.shift();
			
			if (languageIsFirstElement) {
				var lStr : String = pArr[0] == '' ? SiteFacade.getInstance().getLanguage() : pArr[0];
				pArr.shift();
				if (SiteFacade.getInstance().getLanguage() != lStr) {
					if (checkLanguage(lStr)) {
						changeLanguageWithPageLoad = true;
						SiteFacade.getInstance().setLanguage(lStr, false);
						return;
					}
				}
			}
			var mString : String = pArr.join('/');
			if (mString == "") {
				mString = defaultPage;
				pArr = mString.split('/');
			}
			newPageVO = siteData.pageMap[mString];
			
			if (newPageVO == null) {
				pageIsChanging = false;
				if (lastPage == null) {
					SiteFacade.getInstance().setPage(defaultPage);
				}
				return;
			}
			
			lastPage = newPage;
			newPage = newPageVO.id;
			
			newPageArray = new Array();
			for each (var pName:String in pArr) {
				newPageArray.push((siteData.nameMap[pName] as PageVO).id);
			}
			lastTransitionArray = transitionArray;
			transitionArray = siteData.transitionMap[newPageVO.id];
			
			initPageChange();
		}

		/**
		 * trigger beforePageChange in SiteFacade
		 * checks if there's any pre-page change transitions that need to run
		 * if there is, run the transitions with initLoad() as a callback when theyre done
		 * if not, run initLoad()
		 */
		private function initPageChange() : void {
			SiteFacade.getInstance().setTransitionType(newPageVO.transition);
			SiteFacade.getInstance().beforePageChange();
			
			if (currentPage != null) {
				lastPage = currentPage;
				lastPageArray = currentPageArray;
			}
			
			currentPage = newPage;
			currentPageArray = newPageArray;
			
			
			if (currentPage == lastPage && !changeLanguageWithPageLoad) {
				pageIsChanging = false;
				return;
			}
			
			setSiteTitle();
			initLoad();
		}

		private function refreshPage(clearLoadedPageAssets : Boolean = false) : void {
			if (clearLoadedPageAssets) {
				for each (var oPage:IPage in activePages) {
					removePage(oPage);
				}
			}
			isRefreshing = true;
			initPageChange();
		}

		private function checkLanguage(lString : String) : Boolean {
			for each (var lang:String in SUPPORTED_LANGUAGES) {
				if (lString == lang)return true;
			}
			return false;
		}

		private function setPageByID(pageID : String) : * {
			if (pageID == '') {
				setPageByName(defaultPage);
				return;
			}
			var pvo : PageVO = siteData.idMap[pageID];
			if (pvo == null)return;
			var pName : String = pvo.map;
			setPageByName(pName);
		}

		private function setPageByName(pageName : String) : void {
			var pName : String = pageName;
			if (languageIsFirstElement)pName = SiteFacade.getInstance().getLanguage() + '/' + pName;
			SWFAddress.setValue(pName);
		}

		public function getPageChangeLevel() : int {
			return pageChangeLevel;
		}

		private function initLoad() : void {
			removePageLoaderListeners();
			if (pageLoader != null)pageLoader = null;
			pageLoader = new QLoader();
			addPageLoaderListeners();
			pageLoader.addFiles(getFilesToLoad());
			
			MonsterDebugger.trace(pageLoader, pageLoader.files);
			
			SiteFacade.getInstance().beforeLoadPage();
			SiteFacade.getInstance().pageChangeStart();
			
		}

		public function startLoad() : void {
			pageLoader.loadQ();
		}

		private function getFilesToLoad() : Array {
			filesToLoad = new Array();
			getAssetsToLoad(siteData.idMap[newPage], filesToLoad);
			filesToLoad.sortOn('loadIndex');
			
			return filesToLoad;
		}

		private function getAssetsToLoad(pvo : PageVO, filesToLoad : Array) : void {
			while (pvo != null) {
				if (pvo.components.length() > 0) {
					for each (var assetXML:XML in pvo.components) {
						addXMLAsset(assetXML, filesToLoad);
					}
				}
				if (pvo.assets.length > 0) {
					for each (var asset:SiteAssetVO in pvo.assets) {
						addAsset(asset, filesToLoad);
					}
				}
				pvo = siteData.idMap[pvo.parent];
			}
		}

		private function addAsset(asset : SiteAssetVO, assetList : Array) : void {
			if (asset.url == '')return;
			//if (filesLoaded[baseURL asset.url] != null)return;
			assetList.push(new File(baseURL + asset.url, asset.id, asset.weight, asset.index, asset.cache, asset.targetPercent));
		}

		private function addXMLAsset(asset : XML, assetList : Array) : void {
			var avo : SiteAssetVO;
			avo = new SiteAssetVO();
			avo.url = asset.@url.toString();
			avo.id = asset.@id.toString();
			avo.weight = int(asset.@weight) > 0 ? int(asset.@weight) : 1 ;
			avo.index = int(asset.@load_index);
			avo.cache = asset.@cache == "false" ? false : true; 
			avo.targetPercent = int(asset.@target_percent) < 100 ? int(asset.@target_percent) : 100 ;
			addAsset(avo, assetList);
		}

		private function onPageQComplete(event : QEvent) : void {
			cleanUpPageLoader();
			var aArr : Array = new Array();
			var pvo : PageVO;
			for each (var file:File in filesToLoad.reverse()) {
				pvo = siteData.idMap[file.id];
				if (pvo != null) { 
					aArr.push(pvo);
				}
			}
			aArr.sortOn('level');
			
			for each (pvo in aArr) {
				addLoadedPage(pvo.id);
			}
			aArr = null;
			SiteFacade.getInstance().loadPageComplete();
			SiteFacade.getInstance().afterLoadPage();
		}

		private function loadPageComplete() : void {
			if (changeLanguageWithPageLoad)SiteFacade.getInstance().sendNotification(SiteFacade.LANGUAGE_CHANGE, SiteFacade.getInstance().getLanguage());
		}

		private function afterLoadPage() : void {
			if (changeLanguageWithPageLoad)SiteFacade.getInstance().sendNotification(SiteFacade.AFTER_LANGUAGE_CHANGE, SiteFacade.getInstance().getLanguage());
			changeLanguageWithPageLoad = false;
		}

		private function addLoadedPage(id : String) : void {
			if (testingPageComponent)return;
			var aPage : IPage;
			var pvo : PageVO;
			
			for each (aPage in activePages) {
				if (aPage.getPageID() == id)return;
			}
			if (QLibrary.getFileById(id) == null)return;
			
			if (!(QLibrary.getFileById(id).asset is IPage))return;
			try {
				aPage = QLibrary.getFileById(id).asset as IPage;
				aPage.setPageID(id);
				pvo = siteData.idMap[id];
				aPage.setPageContainer(pvo.container);
				aPage.setParent(getActivePage(pvo.parent) as DisplayObjectContainer);
				if (aPage.getPageContainer() != null) {
					if (aPage.getParent().getChildByName(aPage.getPageContainer()) != null) {
						(aPage.getParent().getChildByName(aPage.getPageContainer()) as DisplayObjectContainer).addChild(aPage as DisplayObject);
						return;
					}
				}
				aPage.getParent().addChild(aPage as DisplayObject);
			}catch (e : *) {
				//throw (e);
				MonsterDebugger.trace(this, e);
				return;
			}
		}

		private function pageChangeComplete() : void {
			pageIsChanging = false;
			if (storedPage != null) {
				onSWFAddressChange(null);
				return;
			}
			storedPage = newPage = null;
		}

		private function afterPageChange() : void {
		}

		private function setSiteTitle() : void {
			var pvo : PageVO;
			var tString : String = siteTitle;
			
			for each (var pName:String in newPageArray) {
				pvo = siteData.idMap[pName];
				if (pvo == null || pvo.title == null || pvo.title.toString() == '') continue;
				tString += ' - ' + pvo.title;
			}
			SWFAddress.setTitle(tString);
		}

		
		private function cleanUpPageLoader() : void {
			removePageLoaderListeners();
			pageLoader.clear();
		}

		private function removePageLoaderListeners() : void {
			if (pageLoader == null)return;
			pageLoader.removeEventListener(QEvent.Q_PROGRESS, onPageQProgress);
			pageLoader.removeEventListener(QEvent.Q_COMPLETE, onPageQComplete);
			pageLoader.removeEventListener(QEvent.FILE_COMPLETE, onPageFileComplete);
			pageLoader.removeEventListener(QEvent.Q_PROGRESS, onPageFileProgress);
			pageLoader.removeEventListener(QEvent.Q_ERROR, onPageQError);
		}

		private function addPageLoaderListeners() : void {
			pageLoader.addEventListener(QEvent.Q_PROGRESS, onPageQProgress);
			pageLoader.addEventListener(QEvent.Q_COMPLETE, onPageQComplete);
			pageLoader.addEventListener(QEvent.FILE_COMPLETE, onPageFileComplete);
			pageLoader.addEventListener(QEvent.Q_PROGRESS, onPageFileProgress);
			pageLoader.addEventListener(QEvent.Q_ERROR, onPageQError);
		}

		private function onPageQProgress(event : QEvent) : void {
			facade.sendNotification(SiteFacade.LOAD_PAGE_PROGRESS, event.qPercent);
		}

		private function onPageQError(event : QEvent) : void {
			MonsterDebugger.trace(this, event.errors);
		}

		private function onPageFileProgress(event : QEvent) : void {
		}

		private function onPageFileComplete(event : QEvent) : void {
			filesLoaded[baseURL + event.file.url] = event.file;
		}

		override public function listNotificationInterests() : Array {
			return [SiteFacade.LOAD_DATA,
					SiteFacade.BEFORE_PAGE_REFRESH,
					SiteFacade.PAGE_REFRESH,
					SiteFacade.SET_PAGE_BY_ID,
					SiteFacade.SET_PAGE_BY_NAME,
					SiteFacade.DATA_LOADED,
					SiteFacade.PAGE_ADDED,
					SiteFacade.PAGE_REMOVED,
					SiteFacade.LOAD_PAGE,
					SiteFacade.LOAD_PAGE_COMPLETE,
					SiteFacade.BEFORE_PAGE_ADDED,
					SiteFacade.BEFORE_PAGE_REMOVED,
					SiteFacade.BEFORE_PAGE_COMPONENT_ADDED,
					SiteFacade.PAGE_COMPONENT_ADDED,
					SiteFacade.PAGE_COMPONENT_REMOVED,
					SiteFacade.BEFORE_PAGE_CHANGE,
					SiteFacade.PAGE_CHANGE_START,
					SiteFacade.PAGE_CHANGE_COMPLETE,
					SiteFacade.AFTER_LOAD_PAGE,
                    SiteFacade.AFTER_PAGE_CHANGE];
		}

		private function checkData(page : Object) : Boolean {
			if (siteProxy.getData() != null)return true;
			if (baseURL == null) baseURL = page.getBaseURL();
			languageIsFirstElement = SiteFacade.getInstance().getLanguageIsFirstElement();
			dataPage = page;
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onSWFAddressChange);
			return false;
		}

		
		
		private function loadData(data : Object = null) : void {
			var dataq : QLoader = new QLoader();
			
			var f : File = new File(baseURL + SiteFacade.getInstance().getDataURL(), 'data');
			f.data = data;
			
			dataq.addFile(f);
			
			MonsterDebugger.trace(this, dataq.files);
			dataq.addEventListener(QEvent.Q_COMPLETE, onDataQComplete);
			dataq.loadQ();
		}

		/**
		 * When the page is registered, it checks if the SiteProxy is holding<br>
		 * the data for the site. If not, it triggers the load.
		 */

		private function onDataQComplete(event : QEvent) : void {
			pageIsChanging = false;
			var dataq : QLoader = event.target as QLoader;
			dataq.removeEventListener(QEvent.Q_COMPLETE, onDataQComplete);
			
			siteProxy.setData(event.file.asset);
			siteData = siteProxy.getData() as SiteVO;
			
			if (event.file.data == null) {
				facade.sendNotification(SiteFacade.DATA_CHANGE);
			} else if (event.file.data == 'language') {
				facade.sendNotification(SiteFacade.DATA_CHANGE);
				SiteFacade.getInstance().beforeLanguageChange();
				if (changeLanguageWithPageLoad) {
					onSWFAddressChange(null);
				}
			} else {
				
				SiteFacade.getInstance().dataLoaded(event.file.asset as XML);
				
				if (event.file.data is IPage) {
					defaultPage = IPage(event.file.data).getPageID() != 'site' ? siteData.idMap[(event.file.data as IPage).getPageID()].map : getDefaultPage();
					SiteFacade.getInstance().addPage(event.file.data as IPage);
				}
				if (event.file.data is IPageComponent) {
					testingPageComponent = true;
					defaultPage = IPageComponent(event.file.data).getPageID() != 'site' ? siteData.idMap[(event.file.data as IPageComponent).getPageID()].map : getDefaultPage();
					SiteFacade.getInstance().addPageComponent(event.file.data as IPageComponent);
				}
			}
		
			event.file.data = null;
			dataq = null;
		}

		private function getDefaultPage() : String {
			for each (var page:PageVO in siteData.pageMap) {
				if (page.isDefault)return page.map;
			}
			return '';
		}

		override public function handleNotification( note : INotification ) : void {
			switch (note.getName()) {
				case SiteFacade.LOAD_DATA:
					loadData(note.getBody());
					break;
				case SiteFacade.DATA_LOADED:
					
					break;
				case SiteFacade.LOAD_PAGE:
					startLoad();
					break;
				case SiteFacade.BEFORE_PAGE_ADDED:
					if (!checkData(note.getBody()))return;
					SiteFacade.getInstance().pageAdded(note.getBody() as IPage);
					break;
				case SiteFacade.BEFORE_PAGE_COMPONENT_ADDED:
					if (!checkData(note.getBody()))return;
					SiteFacade.getInstance().componentAdded(note.getBody() as IPageComponent);
					break;
				case SiteFacade.PAGE_ADDED:
					addPage(note.getBody() as IPage);
					break;
				case SiteFacade.BEFORE_PAGE_REMOVED:
					break;
				case SiteFacade.PAGE_CHANGE_START:
					break;
				case SiteFacade.PAGE_CHANGE_COMPLETE:
					pageChangeComplete();
					break;
				case SiteFacade.LOAD_PAGE_COMPLETE:
					loadPageComplete();
					break;
				case SiteFacade.AFTER_LOAD_PAGE:
					afterLoadPage();
					break;
				case SiteFacade.AFTER_PAGE_CHANGE:
					afterPageChange();
					break;
				case SiteFacade.PAGE_REMOVED:
					removePage(note.getBody() as IPage);
					break;
				case SiteFacade.PAGE_COMPONENT_ADDED:
					addPageComponent(note.getBody() as IPageComponent);
					break;
				case SiteFacade.PAGE_COMPONENT_REMOVED:
					removePageComponent(note.getBody() as IPageComponent);
					break;
				case SiteFacade.SET_PAGE_BY_ID:
					setPageByID(String(note.getBody()));
					break;
				case SiteFacade.SET_PAGE_BY_NAME:
					setPageByName(String(note.getBody()));
					break;
				case (SiteFacade.BEFORE_PAGE_REFRESH):
					refreshPage(Boolean(note.getBody()));
					break;
			}
		}

		
		private function addPageComponent(iPageComponent : IPageComponent) : void {
			if (DictionaryUtil.getLength(activePages) == 0) {
				SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onSWFAddressChange);
				if (dataPage != null) {
					dataPage = null;
					onSWFAddressChange(null);
				}
			}
		}

		private function addPage(aPage : IPage) : void {
			setPageLevel(aPage);
			if (DictionaryUtil.getLength(activePages) == 0 && dataPage == null) {
				dataPage = aPage;
				SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onSWFAddressChange);
				return;
			}
			activePages[aPage.getPageID()] = aPage;
			numActivePages++;
			
			if (dataPage != null) {
				dataPage = null;
				onSWFAddressChange(null);
			}
		}

		private function getActivePage(id : String) : IPage {
			return activePages[id];
		}	

		private function removePage(aPage : IPage) : void {
			SiteFacade.getInstance().removeMediator(aPage.getPageID() + 'Mediator');
			SiteFacade.getInstance().removeProxy(aPage.getPageID() + 'Proxy');
			
			DisplayObject(aPage).parent.removeChild(aPage as DisplayObject);
			
			for each (var oPage:IPage in activePages) {
				if (siteData.idMap[oPage.getPageID()].parent == aPage.getPageID()) {
					delete activePages[oPage.getPageID()];
					delete filesLoaded[baseURL + siteData.idMap[oPage.getPageID()].url.toString()];
					numActivePages--;
					removePageAssets(oPage.getPageID());
				}
			}
			delete activePages[aPage.getPageID()];
			delete filesLoaded[baseURL + siteData.idMap[aPage.getPageID()].url.toString()];
			
			numActivePages--;
			removePageAssets(aPage.getPageID());
			numActivePages = activePages.length;
		}

		private function removePageAssets(pageID : String) : void {
			removeAssetsByID(pageID);
		}

		private function removeAssetsByID(pageID : String) : void {
			var pvo : PageVO = siteData.idMap[pageID];
			for each (var pAsset:SiteAssetVO in pvo.assets) {
				delete filesLoaded[baseURL + pAsset.url];
			}
		}

		private function removePageComponent(aPageComponent : IPageComponent) : void {
			SiteFacade.getInstance().removeMediator(aPageComponent.getPageID() + aPageComponent.getComponentID() + 'Mediator');
			SiteFacade.getInstance().removeProxy(aPageComponent.getPageID() + aPageComponent.getComponentID() + 'Proxy');
		
			//DisplayObject(aPageComponent).parent.removeChild(aPageComponent as DisplayObject);
		}

		private function setPageLevel(pageToSet : IPage) : void {
			var pvo : PageVO = siteData.idMap[pageToSet.getPageID()];
			pageToSet.setLevel(pvo.level);
			pageChangeLevel = pvo.level;
		}

		public function getActivePages() : Dictionary {
			return activePages;
		}

		public function getPageArray() : Array {
			return currentPageArray;
		}

		public function getPageID() : String {
			return currentPage;
		}

		public function getNewPageArray() : Array {
			return newPageArray;
		}

		public function getNewPageID() : String {
			return newPage;
		}

		public function getLastPageArray() : Array {
			return lastPageArray;
		}

		public function getLastPageID() : String {
			return lastPage;
		}

		public function getLastPageName() : String {
			return getPageNameFromArray(lastPageArray);
		}

		public function getPageName() : String {
			return getPageNameFromArray(currentPageArray);
		}

		public function getNewPageName() : String {
			return getPageNameFromArray(newPageArray);
		}

		public function getTransitionArray() : Array {
			return transitionArray;
		}

		
		public function getLastTransitionArray() : Array {
			return lastTransitionArray;
		}

		private function getPageNameFromArray(arrayToUse : Array) : String {
			var arr : Array = new Array();
			for each (var pID:String in arrayToUse) {
				arr.push(siteData.idMap[pID].name);
			}
			arr.shift();
			return arr.join('/');
		}

		public function setPageTransitionType(pageID : String, value : String) : void {
			if (siteData == null)return;
			if (siteData.idMap[pageID] == null)return;
			siteData.idMap[pageID].transition = value;
		}
	}
}

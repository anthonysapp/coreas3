package core.site.view.mediators {
	import org.puremvc.as3.interfaces.INotification;

	import core.site.SiteFacade;

	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * @author anthonysapp
	 */
	public class LanguageMediator extends Mediator {
		public static const NAME : String = 'LanguageMediator';
		protected var language : String = 'en';

		public function LanguageMediator(mediatorName : String = null, viewComponent : Object = null) {
			super(NAME, viewComponent);
		}

		override public function onRegister() : void {
			setLanguage();
		}

		private function setLanguage() : void {
			if (language == SiteFacade.getInstance().getLanguage())return;
			language = SiteFacade.getInstance().getLanguage();
			SiteFacade.getInstance().loadData('language');
		}

		public function getDataURL() : String {
			if (language == 'en') return 'assets/xml/site.xml';
			return 'assets/xml/site_' + language + '.xml';
		}

		override public function listNotificationInterests() : Array {
			return [SiteFacade.SET_LANGUAGE,
					SiteFacade.BEFORE_LANGUAGE_CHANGE,
					SiteFacade.LANGUAGE_CHANGE,
					SiteFacade.AFTER_LANGUAGE_CHANGE,
					SiteFacade.BEFORE_PAGE_REFRESH,
					SiteFacade.PAGE_REFRESH,
					SiteFacade.AFTER_PAGE_REFRESH];
		}

		protected function beforeLanguageChange() : void {
			
		}

		
		protected function languageChange() : void {
		}

		protected function afterLanguageChange() : void {
		}

		private function beforePageRefresh() : void {
		}

		private function pageReresh() : void {
		}

		private function afterPageRefresh() : void {
			
		}

		override public function handleNotification( note : INotification ) : void {
			switch (note.getName()) {
				case SiteFacade.SET_LANGUAGE:
					setLanguage();
					break;
				case SiteFacade.BEFORE_LANGUAGE_CHANGE:
					beforeLanguageChange();
					break;
				case SiteFacade.LANGUAGE_CHANGE:
					languageChange();
					break;
				case SiteFacade.AFTER_LANGUAGE_CHANGE:
					afterLanguageChange();
					break;
				case SiteFacade.BEFORE_PAGE_REFRESH:
					beforePageRefresh();
					break;
				case SiteFacade.PAGE_REFRESH:
					pageReresh();
					break;
				case SiteFacade.AFTER_PAGE_REFRESH:
					afterPageRefresh();
					break;
			}
		}
	}
}

package core.site.view.mediators {
	import core.site.interfaces.IPreloader;

	import org.puremvc.as3.interfaces.INotification;

	import core.site.SiteFacade;

	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * @author anthonysapp
	 */
	public class PreloaderMediator extends Mediator {
		public function PreloaderMediator(mediatorName : String = null, viewComponent : Object = null) {
			super(mediatorName, viewComponent);
		}

		override public function listNotificationInterests() : Array {
			return [SiteFacade.BEFORE_LOAD_PAGE,
					SiteFacade.LOAD_PAGE_PROGRESS,
                    SiteFacade.LOAD_PAGE_COMPLETE,
                    SiteFacade.AFTER_LOAD_PAGE,
                    SiteFacade.BEFORE_TRANSITION_IN,
                    SiteFacade.AFTER_TRANSITION_IN,
                    SiteFacade.BEFORE_TRANSITION_OUT,
                    SiteFacade.AFTER_TRANSITION_OUT];
		}

		override public function handleNotification( note : INotification ) : void {
			switch (note.getName()) {
				case SiteFacade.LOAD_PAGE_PROGRESS:
					preloader.onPageLoadProgress(Number(note.getBody()));
					break;
				case SiteFacade.BEFORE_LOAD_PAGE:
					preloader.onBeforeLoadPage();
					break;
				case SiteFacade.LOAD_PAGE_COMPLETE:
					preloader.onLoadPageComplete();
					break;
				case SiteFacade.AFTER_LOAD_PAGE:
					preloader.onAfterLoadPage();
					break;
				case SiteFacade.BEFORE_TRANSITION_IN:
					preloader.onBeforeTransitionIn();
					break;
				case SiteFacade.AFTER_TRANSITION_IN:
					preloader.onAfterTransitionIn();
					break;
				case SiteFacade.BEFORE_TRANSITION_OUT:
					preloader.onBeforeTransitionOut();
					break;
				case SiteFacade.AFTER_TRANSITION_OUT:
					preloader.onAfterTransitionOut();
					break;
			}
		}
		protected function get preloader():IPreloader{
			return IPreloader(viewComponent);
		}
	}
}

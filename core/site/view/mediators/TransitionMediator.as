package core.site.view.mediators {
	import core.site.interfaces.ITransition;

	import org.puremvc.as3.patterns.mediator.Mediator;

	import core.site.SiteFacade;

	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.interfaces.IMediator;

	/**
	 * @author anthonysapp
	 */
	public class TransitionMediator extends Mediator implements IMediator {
		public static const NAME : String = "TransitionMediator";
		protected var transitionHandler : ITransition;

		public function TransitionMediator() : void {
			super(NAME);
		}

		private function setTransitionHandler(transitionHandler : Object) : void {
			this.transitionHandler = transitionHandler as ITransition;
		}

		private function loadPage() : void {
		}

		private function beforeLoadPage() : void {
			transitionHandler.beforeLoadPage();
		}

		private function afterLoadPage() : void {
			transitionHandler.afterLoadPage();
		}

		private function afterAllTransitions() : void {
			transitionHandler.afterAllTransitions();
		}

		private function beforeTransitionIn() : void {
		}

		private function transitionIn() : void {
		}

		private function afterTransitionIn() : void {
			transitionHandler.afterTransitionIn();
		}

		private function beforeTransitionOut() : void {
		}

		private function transitionOut() : void {
		}

		private function afterTransitionOut() : void {
			transitionHandler.afterTransitionOut();
		}		

		override public function listNotificationInterests() : Array {
			return [SiteFacade.SET_TRANSITION_TYPE,
					SiteFacade.BEFORE_LOAD_PAGE,
					SiteFacade.LOAD_PAGE,
					SiteFacade.AFTER_LOAD_PAGE,
					SiteFacade.BEFORE_TRANSITION_IN,
					SiteFacade.TRANSITION_IN,
					SiteFacade.AFTER_TRANSITION_IN,
					SiteFacade.BEFORE_TRANSITION_OUT, 
					SiteFacade.AFTER_TRANSITION_OUT,
					SiteFacade.TRANSITION_OUT,
					SiteFacade.AFTER_ALL_TRANSITIONS];
		}

		override public function handleNotification(notification : INotification) : void {
			switch (notification.getName()) {
				case SiteFacade.SET_TRANSITION_TYPE:
					setTransitionHandler(notification.getBody());
					break;
				case SiteFacade.BEFORE_LOAD_PAGE:
					beforeLoadPage();
					break;
				case SiteFacade.LOAD_PAGE:
					loadPage();
					break;
				case SiteFacade.AFTER_LOAD_PAGE:
					afterLoadPage();
					break;
				case SiteFacade.BEFORE_TRANSITION_IN:
					beforeTransitionIn();
					break;
				case SiteFacade.TRANSITION_IN:
					transitionIn();
					break;
				case SiteFacade.AFTER_TRANSITION_IN:
					afterTransitionIn();
					break;
				case SiteFacade.BEFORE_TRANSITION_OUT:
					beforeTransitionOut();
					break;
				case SiteFacade.TRANSITION_OUT:
					transitionOut();
					break;
				case SiteFacade.AFTER_TRANSITION_OUT:
					afterTransitionOut();
					break;
				case SiteFacade.AFTER_ALL_TRANSITIONS:
					afterAllTransitions();
				break;
			}
		}

		
		override public function onRegister() : void {
		}

		override public function onRemove() : void {
			transitionHandler = null;
		}
	}
}

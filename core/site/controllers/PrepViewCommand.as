package core.site.controllers {
	import core.site.view.mediators.TransitionMediator;
	import core.site.view.mediators.SiteMediator;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * @author anthonysapp
	 */
	public class PrepViewCommand extends SimpleCommand {
		public function PrepViewCommand() {
			facade.registerMediator(new SiteMediator());
            facade.registerMediator(new TransitionMediator());
		}
	}
}

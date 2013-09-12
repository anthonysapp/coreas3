package core.site.controllers {
	import core.site.view.mediators.LanguageMediator;

	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * @author anthonysapp
	 */
	public class SetLanguageCommand extends SimpleCommand {
		override public function execute(note : INotification ) : void {
			if (facade.hasMediator(LanguageMediator.NAME))return;
			facade.registerMediator(new LanguageMediator(LanguageMediator.NAME, note.getBody()));
		}
	}
}

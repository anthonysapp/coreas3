package core.site.controllers {
	import core.site.interfaces.IPage;
	import core.site.model.PageProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * @author anthonysapp
	 */
	public class PrepPageCommand extends SimpleCommand {
		override public function execute( notification : INotification ) : void {
			var page:IPage = notification.getBody() as IPage;
			facade.registerProxy(new PageProxy(page.getPageID()+'Proxy'));
			var pMediator:Class = page.getPageMediator();
			facade.registerMediator(new pMediator(page.getPageID()+'Mediator',notification.getBody()));
		}
	}
}

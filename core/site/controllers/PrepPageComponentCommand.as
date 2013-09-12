package core.site.controllers {
	import core.site.view.mediators.PageComponentMediator;
	import core.site.model.PageComponentProxy;
	import org.puremvc.as3.interfaces.INotification;
	import core.site.interfaces.IPageComponent;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * @author anthonysapp
	 */
	public class PrepPageComponentCommand extends SimpleCommand {
		override public function execute( notification : INotification ) : void {
			var component:IPageComponent = notification.getBody() as IPageComponent;
			facade.registerProxy(new PageComponentProxy(component.getPageID() + component.getComponentID()+'Proxy'));
			facade.registerMediator(new PageComponentMediator(component.getPageID() + component.getComponentID()+'Mediator',component));
		}
	}
}

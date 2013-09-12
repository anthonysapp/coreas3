package core.site.controllers {
	import core.site.model.SiteProxy;

	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * @author anthonysapp
	 */
	public class PrepModelCommand extends SimpleCommand
    {
        override public function execute (note:INotification ) : void
        {
            facade.registerProxy(new SiteProxy());
        }
    }

}

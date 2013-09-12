package core.site.controllers {
	import org.puremvc.as3.patterns.command.MacroCommand;

	/**
	 * @author anthonysapp
	 */
	public class StartupCommand extends MacroCommand {
		override protected function initializeMacroCommand() : void {
			addSubCommand(PrepModelCommand);
			addSubCommand(PrepViewCommand);
		}
	}
}

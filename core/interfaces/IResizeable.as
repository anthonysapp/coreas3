package core.interfaces {
	import flash.events.Event;	

	/**
	 * @author anthonysapp
	 */
	public interface IResizeable {
		function onStageResize(event : Event = null) : void;
	}
}

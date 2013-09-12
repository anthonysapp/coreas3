package core.site.interfaces {

	/**
	 * @author anthonysapp
	 */
	public interface IPreloader {
		function onPageLoadProgress(percent:Number) : void;

		function onBeforeLoadPage() : void;

		function onLoadPageComplete() : void;

		function onAfterLoadPage() : void;

		function onBeforeTransitionIn() : void;

		function onAfterTransitionIn() : void;

		function onBeforeTransitionOut() : void;

		function onAfterTransitionOut() : void;
	}
}

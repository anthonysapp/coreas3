package core.site.view.components {
	import core.site.interfaces.IPreloader;
	import core.site.view.mediators.PreloaderMediator;
	import core.site.SiteFacade;
	import core.display.StateClip;

	/**
	 * @author anthonysapp
	 */
	public class Preloader extends StateClip implements IPreloader {
		public var id:String = "Preloader";
		//
		public var percent:Number;
		public function Preloader() {
			super();
		}
		override protected function init():void{
			SiteFacade.getInstance().registerMediator(new PreloaderMediator(id+"Mediator",this));
		}
		public function setPercent():void{
			//override
		}
		public function onPageLoadProgress(percent:Number) : void {
			this.percent = percent;
			setPercent ();
		}
		
		public function onBeforeLoadPage() : void {
		}
		
		public function onLoadPageComplete() : void {
		}
		
		public function onAfterLoadPage() : void {
		}
		
		public function onBeforeTransitionIn() : void {
		}
		
		public function onAfterTransitionIn() : void {
		}
		
		public function onBeforeTransitionOut() : void {
		}
		
		public function onAfterTransitionOut() : void {
		}
	}
}

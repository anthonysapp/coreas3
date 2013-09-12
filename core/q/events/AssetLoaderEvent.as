package core.q.events {
	import flash.events.Event;

	/**
	 * @author anthonysapp
	 */
	public class AssetLoaderEvent extends Event {
		public static const FILE_START:String ='fileStart';
		public static const FILE_PROGRESS:String = 'fileProgress';
		public static const FILE_COMPLETE:String = 'fileComplete';
		public static const FILE_ERROR:String = 'fileError';
		public static const FAIL:String = 'fileFail';
		
		public function AssetLoaderEvent(type : String) {
			super(type, true, true);
		}
		
	}
}

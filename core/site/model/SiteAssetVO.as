package core.site.model {

	/**
	 * @author anthonysapp
	 */
	public class SiteAssetVO {
		public var url : String;
		public var id : String;
		public var weight : int;
		public var index : int = 0;
		public var cache : Boolean;
		public var targetPercent : int = 100;
	}
}

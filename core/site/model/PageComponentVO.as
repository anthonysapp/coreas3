package core.site.model {

	/**
	 * @author anthonysapp
	 */
	public class PageComponentVO {
		public var id:String;
		public var name:String;
		public var parent:String;
		public var container:String;
		public var content:XMLList;
		public var url:String;
		public var cache:Boolean;
		public var weight : int;
	}
}

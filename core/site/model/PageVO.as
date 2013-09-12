package core.site.model {

	/**
	 * @author anthonysapp
	 */
	public class PageVO {
		public var id:String;
		public var name:String;
		public var title:String;
		public var map:String;
		public var transitionMap:Array;
		public var parent:String;
		public var container:String;
		public var level:int;
		public var page:Object;
		public var sitemap:Boolean;
		public var assets:Array;
		public var components:XMLList;
		public var content:Object;
		public var url:String;
		public var cache:Boolean;
		public var isDefault : Boolean;
		public var weight : int;
		public var transition:String = 'normal';
		public var active : String = 'normal';
	}
}

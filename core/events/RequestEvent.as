package core.events {
	/**
	 * @author anthonysapp
	 */
	import flash.events.Event;

	public class RequestEvent extends Event {
		// **********************************************
		// Public static constants
		public static  const UPLOAD_COMPLETE : String = 'uploadComplete';
		public static  const COMPLETE : String = 'complete';
		public static  const OPEN : String = 'open';
		public static  const PROGRESS : String = 'progress';
		public static  const ERROR : String = 'error';
		public static  const HTTPSTATUS : String = 'httpStatus';
		// **********************************************
		// Public variables
		/**
		 * 
		 * the id associated with the request
		 */
		public var id : *;
		public var bytesLoaded : Number;
		public var bytesTotal : Number;
		public var error : String;
		/**
		 * the data associated with the request
		 */
		public var data : *;

		// **********************************************
		// Constructor
		public function RequestEvent(type : String,id : *= null,data : * = null, bytesLoaded : Number = 0, bytesTotal : Number = 0, error : String = null) {
			this.id = id;
			this.data = data;
			this.bytesLoaded = bytesLoaded;
			this.bytesTotal = bytesTotal;
			this.error = error;
			super(type, true, true);
		}

		// **********************************************
		// Clone override
		override public function clone() : Event {
			return new RequestEvent(type, this.id, this.data, this.bytesLoaded, this.bytesTotal, this.error);
		}
	}
}

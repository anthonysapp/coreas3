package core.q.events {
	import core.q.File;	

	import flash.events.Event;
	/**
	 * Event dispatched by the @see QLoader
	 * @author Sapp
	 * @version 1
	 */
	public class QEvent extends Event {
		public static const Q_START : String = 'qstart';
		public static const Q_COMPLETE : String = 'qcomplete';
		public static const Q_PROGRESS : String = 'qprogress';
		public static const FILE_START : String = 'qfilestart';
		public static const FILE_PROGRESS : String = 'qfileprogress';
		public static const FILE_COMPLETE : String = 'qfilecomplete';
		public static const Q_ERROR : String = 'error';
		//
		/**
		 * the current <a href=../q/File.html>File</a> being loaded by the <a href=../../QLoader.html>QLoader</a>
		 */
		public var file : File;
		/**
		 * the errors encountered by the <a href=../QLoader.html>QLoader</a> while loading the queue
		 */
		public var errors : String;
		/**
		 * the total bytes currently loaded by the <a href=../QLoader.html>QLoader</a>
		 */
		public var qBytesLoaded : Number;
		/**
		 * the total bytes to be loaded by the <a href=../QLoader.html>QLoader</a>
		 */
		public var qBytesTotal : Number;
		/**
		 * the total percent of the <a href=../QLoader.html>QLoader</a>'s queue that has been loaded (0-100)
		 */
		public var qPercent : Number;
		/**
		 * the load percent of the current file being loaded by the <a href=../QLoader.html>QLoader</a>
		 */
		public var filePercent : Number;
		/**
		 * the bytes loaded of the current file being loaded by the <a href=../QLoader.html>QLoader</a>
		 */
		public var fileBytesLoaded : Number;
		/**
		 * the total bytes to be loaded of the current file being loaded by the <a href=../QLoader.html>QLoader</a>
		 */
		public var fileBytesTotal : Number;
		/**
		 * the amount of time that has passed since the <a href=../QLoader.html>QLoader</a> started loading the queue
		 */
		
		public var time:Number;
		/**
		 * the number of the file that was loaded
		 */
		public var index:int;
		
		public var id:String;

		public function QEvent(type : String, id:String, qpercent : Number = 0, qbytes : Number = 0, qtotal : Number = 0, filepercent : Number = 0, filebytes : Number = 0, filetotal : Number = 0,file : File = null, fileIndex:int = -1, time:Number=0 , error : String = null ) {
			this.qPercent = qpercent;
			this.qBytesTotal = qtotal;
			this.qBytesLoaded = qbytes;
			//
			this.filePercent = filepercent;
			this.fileBytesLoaded = filebytes;
			this.fileBytesTotal = filetotal;
			//
			this.file = file;
			this.index = fileIndex;
			this.time = time;
			this.errors = error;
			//
			this.id = id;
			super(type, true, true);
		}
		override public function clone() : Event {
			return new QEvent(type, this.id, this.qPercent, this.qBytesLoaded, this.qBytesTotal, this.filePercent, this.fileBytesLoaded, this.fileBytesTotal, this.file, this.index, this.time, this.errors);
		}	}
}

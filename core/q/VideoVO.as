package core.q {
	import flash.net.NetConnection;
	import flash.net.NetStream;

	/**
	 * @author anthonysapp
	 */
	public class VideoVO {
		public var netStream:NetStream;
		public var netConnection:NetConnection;
		public var metaData:MetaDataVO;
		public var url : String;
	}
}

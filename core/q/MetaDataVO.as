package core.q {

	/**
	 * @author anthonysapp
	 */
	public class MetaDataVO extends Object{
		public var audioCodecID:int;		public var audioDataRate:int;		public var audioDelay:Number;		public var canSeekToEnd:Boolean;		public var duration:Number;		public var frameRate:int;
		public var videoCodecID:int;		public var videoDataRate:int;		public var width:int;		public var height:int;
		
		public function MetaDataVO(obj:Object){
			this.audioCodecID = obj.audiocodecid;
			this.audioDataRate = obj.audiodatarate;
			this.audioDelay = obj.audiodelay;
			this.canSeekToEnd = obj.canSeekToEnd;
			this.duration = obj.duration;
			this.frameRate = obj.frameRate;
			this.videoCodecID = obj.videocodecid;
			this.videoDataRate = obj.videodatarate;
			this.width = obj.width;
			this.height = obj.height;
		}
	}
}

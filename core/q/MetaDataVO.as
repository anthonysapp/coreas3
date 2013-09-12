package core.q {

	/**
	 * @author anthonysapp
	 */
	public class MetaDataVO extends Object{
		public var audioCodecID:int;
		public var videoCodecID:int;
		
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
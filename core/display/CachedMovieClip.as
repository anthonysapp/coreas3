package core.display {
	import flash.utils.Dictionary;
	import flash.display.PixelSnapping;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.display.Sprite;

	/**
	 * @author anthonysapp
	 */
	public class CachedMovieClip extends Sprite {
		protected var _obj : Object;
		protected var _lookup : Dictionary;
		protected var currentIndex : int = 1;
		//
		public var currentFrame : uint = 1;
		public var totalFrames : int = 0;
		public var bitmap : Bitmap;
		protected var _bmd : BitmapData;
		//
		protected var isPlaying : Boolean = false;
		protected var isPlayingRandom : Boolean = false;
		protected var isRewinding : Boolean = false;

		public function CachedMovieClip(cachedObj : Object = null) {
			if (cachedObj != null)setCached(cachedObj);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}

		private function onRemovedFromStage(event : Event) : void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			removeAllListeners();
			_obj = null;
			_lookup = null;
			removeChild(bitmap);
			isPlaying = isRewinding = isPlayingRandom = false;
		}
		
		public function setCached(cachedObj : Object) : void {
			_obj = cachedObj;
			_createLookup();
		}

		public function play() : void {
			if (_obj == null) {
				throw (new Error('CachedMovieClip:: you must set a cached object in order to use the play() method'));
				return;
			}
			isPlaying = true;
			addEventListener(Event.ENTER_FRAME, nextFrame);
		}

		public function rewind() : void {
			if (_obj == null) {
				throw (new Error('CachedMovieClip:: you must set a cached object in order to use the play() method'));
				return;
			}
			isPlaying = true;
			addEventListener(Event.ENTER_FRAME, prevFrame);
		}

		public function playRandom() : void {
			if (_obj == null) {
				throw (new Error('CachedMovieClip:: you must set a cached object in order to use the play() method'));
				return;
			}
			isPlaying = true;
			addEventListener(Event.ENTER_FRAME, randomFrame);
		}

		public function stop() : void {
			removeAllListeners();
			isPlaying = isPlayingRandom = isRewinding = false;
		}

		protected function removeAllListeners() : void {
			removeEventListener(Event.ENTER_FRAME, nextFrame);
			removeEventListener(Event.ENTER_FRAME, randomFrame);
			removeEventListener(Event.ENTER_FRAME, prevFrame);
		}

		private function randomFrame(event : Event = null) : void {
			currentIndex = Math.ceil(Math.random() * totalFrames);
			bitmap.bitmapData = _lookup[currentIndex]['sprite'];
			currentFrame = currentIndex ;
		}

		private function prevFrame(event : Event = null) : void {
			if (currentFrame <=0) {
				currentIndex = currentFrame = totalFrames;
			}
			currentIndex--;
			bitmap.bitmapData = _lookup[currentIndex]['sprite'];
		}

		public function nextFrame(event : Event = null) : void {
			if (currentFrame > totalFrames || currentFrame <= 0 || currentIndex <= 0) {
				currentIndex = 1;
			}
			bitmap.bitmapData = _lookup[currentIndex].sprite;
			
			currentIndex++;
			currentFrame = currentIndex;
		}

		protected function _createLookup() : void {
			_lookup = new Dictionary();
			var count : int = 0;
			for (var frame:* in _obj) {
				if (frame is int)count++;
				_lookup[frame] = {frame:frame, sprite:_obj[frame]};
			}
			totalFrames =  count;
			//
			_bmd = _lookup[1].sprite;
			bitmap = addChild(new Bitmap(_bmd, PixelSnapping.AUTO, true)) as Bitmap;
		}
	}
}

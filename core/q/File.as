package core.q {
	import flash.net.NetStream;
	import flash.media.Sound;
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	import flash.text.StyleSheet;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;

	/**
	 * @author anthonysapp
	 */
	public class File {
		public static const IMAGE_FILE : String = 'image';
		public static const SWF_FILE : String = 'swf';
		public static const SOUND_FILE : String = 'sound';
		public static const VIDEO_FILE : String = 'video';
		public static const TEXT_FILE : String = 'text';
		public static const XML_FILE : String = 'xml';
		public static const CSS_FILE : String = 'css';
		/*
		 * initial variables populated from constructor
		 */
		public var url : String;
		public var id : String;
		public var group : * = null;
		public var weight : int = 1;
		public var loadIndex : int = 9999;
		public var targetPercent : int = 100;
		public var libraryItem : Boolean = false;
		public var target : DisplayObjectContainer = null;

		/*
		 * variables to be populated during / after load
		 */
		public var type : String;
		public var bitmapData : BitmapData;
		public var mc : DisplayObject;
		public var video : VideoVO;
		public var sound : Sound;
		public var xml : XML;
		public var css : StyleSheet;
		public var data : *;
		public var width : Number;
		public var height : Number;
		public var bytesLoaded : uint;
		public var bytesTotal : uint;
		public var cache : Boolean = true;
		public var drawBitmap:Boolean = true;

		/*
		 * publicly accessible variables
		 */
		public var extension : String;

		/*
		 * asset - can be anything
		 */
		private var _asset : *;
		public var loaded : Boolean = false;
		public var isValid : Boolean= true;
		

		
		public function File(url : String, id : String = null, weight : int = 1, loadIndex : int = 1000, cache : Boolean = true,targetPercent : int = 100, libraryItem : Boolean = false, target : DisplayObjectContainer = null, group : * = null, fileType:String = null, drawBitmap:Boolean = true ) {
			this.url = url;
			this.id = id == null ? url : id;
			this.weight = weight;
			this.targetPercent = targetPercent <= 0 ? 100 : targetPercent ;
			this.libraryItem = libraryItem;
			this.target = target;
			this.group = group;
			this.loadIndex = loadIndex;
			this.cache = cache;
			this.drawBitmap = drawBitmap;
			
			extension = url.substr(url.length - 3, url.length - 1);
			type = fileType == null ? getType() : fileType;
			if (type == null) {
				isValid = false;
				trace('the file "'+ url +'" is not supported because the extension is not valid.');
				destroy();
			}
		}

		private function getType() : String {
			var result : String = '';
			switch (extension.toLowerCase()) {
				case 'jpg' :
				case 'png':
				case 'gif':
					result = File.IMAGE_FILE;
					break;
				case 'flv':
				case 'f4v':
					result = File.VIDEO_FILE;
					video = new VideoVO();
					break;
				case 'mp3':
					result = File.SOUND_FILE;
					break;
				case 'css' :
					result = File.CSS_FILE;
					break;
				case 'xml' :
					result = File.XML_FILE;
					break;
				case 'swf':
					result = File.SWF_FILE;
					break;
				case 'txt' :
					result = File.TEXT_FILE;
					break;
			}
			return result == '' ? null : result;
		}
		private function setAsset() : void {
			switch (type) {
				case IMAGE_FILE:
					_asset = drawBitmap ? new Bitmap(bitmapData) : mc;
					break;
				case VIDEO_FILE:
					_asset = video;
					break;
				case SOUND_FILE:
					_asset = sound;
					break;
				case CSS_FILE:
					_asset = css;
					break;
				case XML_FILE:
					_asset = xml;
					break;
				case SWF_FILE:
					_asset = mc;
					break;
				case TEXT_FILE:
					_asset = data;
					break;
			}
		}

		public function get asset() : Object {
			if (_asset == null)setAsset();
			return _asset;
		}

		public function destroy() : void {
			_asset = null;
			
			mc = null;
			data = null;
			xml = null;
			url = null;
			group = null;
			
			if (bitmapData != null) {
				bitmapData.dispose(); 
				bitmapData = null;
			}
		}
		
		public function toString():String{
			return 'File:: id: ' + id + ', url: ' + url;
		}
	}
}

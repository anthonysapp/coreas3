package core.q {
	import flash.display.DisplayObject;
	import flash.events.NetStatusEvent;
	import flash.display.Sprite;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	import flash.media.SoundLoaderContext;

	import core.utils.CacheUtil;
	import core.q.events.AssetLoaderEvent;

	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.events.ErrorEvent;

	import core.utils.BitmapUtil;

	import flash.net.URLRequest;
	import flash.events.SecurityErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.text.StyleSheet;
	import flash.net.URLLoaderDataFormat;
	import flash.media.Sound;
	import flash.display.Loader;
	import flash.net.URLLoader;

	import core.q.File;

	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	/**
	 * @author anthonysapp
	 */
	public class AssetLoader extends EventDispatcher {
		public var id : String = 'AssetLoader';
		public var file : File;
		public var context : LoaderContext;
		public var percentLoaded : Number;
		public var weightLoaded : Number;

		public var bytesLoaded : uint;
		public var bytesTotal : uint;

		public var errors : Array;

		private var loader : *;
		public var isLoading : Boolean = false;
		public var dummy : Sprite;
		//
		private var completeOnMetaData : Boolean = false;

		
		public function AssetLoader(target : IEventDispatcher = null) {
		}

		public function loadFile(fileToLoad : File) : void {
			file = fileToLoad;
			errors = new Array();
			loader = getLoader();
			if (loader == null) {
				onFileComplete(null);
				return;
			}
			
			addListeners();
			var request : URLRequest = new URLRequest(file.cache ? file.url : CacheUtil.create(file.url));
			isLoading = true;
			if (loader is Loader) {
				if (context == null) {
					context = new LoaderContext();
					context.applicationDomain = ApplicationDomain.currentDomain;
					context.checkPolicyFile = true;
				}
				loader.load(request, context);
				return;
			}
			else if (loader is NetStream) {
				if (dummy == null) dummy = new Sprite();
				(loader as NetStream).play(request.url, true);
				(loader as NetStream).pause();
				dummy.addEventListener(Event.ENTER_FRAME, onNetStreamEnterFrame, false, 0, true);
			}
			else if (loader is Sound) {
				var slc : SoundLoaderContext = new SoundLoaderContext();
				loader.load(request, slc);
				return;
			} else {
				loader.load(request);
			}
		}

		private function onNetStreamEnterFrame(event : Event) : void {
			var event : Event;
			/*if ((loader is NetStream) == false) {
			if (dummy) dummy.removeEventListener(Event.ENTER_FRAME, onNetStreamEnterFrame, false);
			return;
			}*/
			if(loader.bytesTotal == loader.bytesLoaded && loader.bytesTotal > 8) {
				if (dummy) dummy.removeEventListener(Event.ENTER_FRAME, onNetStreamEnterFrame, false);
				event = new Event(Event.COMPLETE);
				if (file.asset.metaData == null) {
					completeOnMetaData = true;
				} else {
					(loader as NetStream).seek(0);
					onFileComplete(event);
				}
			} else {
				event = new ProgressEvent(ProgressEvent.PROGRESS, false, false, loader.bytesLoaded, loader.bytesTotal);
				onFileProgress(event as ProgressEvent);
			}
		}

		private function onNetStatus(event : NetStatusEvent) : void {
			if(!loader) {
				return;
			}
			loader.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false);
			
			if(event.info.code == "NetStream.Play.StreamNotFound") {
				onError(event);
			}
		}

		public function clear(unload : Boolean = true) : void {
			removeListeners();
			if (unload) {
				if (loader is Loader) {
					var l : Loader = loader as Loader;
					try {
						l.unload();
					}catch (e : *) {
					}
				}
				loader = null;
				file.destroy();
				file = null;
			}
			
			isLoading = false;
			context = null;
			errors = null;
			percentLoaded = bytesLoaded = bytesTotal = 0;
			
			if (loader is NetStream) return;
			try {
				loader.close();
			}catch (e2 : *) {
			}	
		}

		private function addListeners() : void {
			removeListeners();
			if (loader == undefined) {
				onError(new ErrorEvent(ErrorEvent.ERROR, true, false, 'The loader was undefined. This probably means the url is not valid.'));
				return;
			}
			if (loader is Loader) {
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onFileProgress);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onFileComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
				return;
			}else if (loader is NetStream) {
				loader.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			}
			loader.addEventListener(ProgressEvent.PROGRESS, onFileProgress);
			loader.addEventListener(Event.COMPLETE, onFileComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		}

		private function removeListeners() : void {
			if (loader == null || loader == undefined)return;
			if (loader is Loader) {
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onFileProgress);
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onFileComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
				return;
			}else if (loader is NetStream) {
				loader.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false);
			}
			loader.removeEventListener(ProgressEvent.PROGRESS, onFileProgress);
			loader.removeEventListener(Event.COMPLETE, onFileComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		}

		private function onFileProgress(event : ProgressEvent) : void {
			bytesTotal = event.bytesTotal;
			bytesLoaded = event.bytesLoaded;
			
			file.bytesTotal = event.bytesTotal;
			file.bytesLoaded = event.bytesLoaded;
			
			percentLoaded = bytesLoaded / bytesTotal * 100;
			weightLoaded = (bytesLoaded / bytesTotal * file.weight) * (100 / file.targetPercent);
			
			if (percentLoaded >= 100) percentLoaded = 100;
			if (weightLoaded >= file.weight) weightLoaded = file.weight;
			
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.FILE_PROGRESS));
			
			if (file.targetPercent < 100 && percentLoaded >= file.targetPercent) {
				try {
					loader.dispatchEvent(new Event(Event.COMPLETE, true, true));
				} catch (e : *) {
					//MonsterDebugger.trace(this, e);
				}
				return;
			}
		}

		private function onFileComplete(event : Event) : void {
			if (event != null) {
				file.loaded = true;
				if (loader is Loader) {
					file.width = loader.width;
					file.height = loader.height;
					if (file.extension != 'swf' && file.drawBitmap) {
						try {
							file.bitmapData = BitmapUtil.makeBitmapData(loader.content);
						}catch (e : *) {
							trace (e.message);
							//MonsterDebugger.trace(this, e.message);
						}
					} else {
						file.mc = file.type == File.IMAGE_FILE ? loader : Loader(loader).content;
					}
					if (file.target != null) {
						try {
							file.target.addChild(file.asset as DisplayObject);
						}catch (e : Error) {
							trace(e.getStackTrace());
						}
					}
				} else {
					switch (file.extension) {
						case 'mp3':
						case 'wav':
							file.sound = loader;
							break;
						case 'xml' :
							file.xml = new XML(loader.data);
							break;
						case 'css' :
							file.css = new StyleSheet();
							file.css.parseCSS(loader.data);
							break;
						case 'txt' :
							file.data = loader.data;
							break;
						case 'flv':
						case 'f4v':
							(file.asset as VideoVO).netStream = loader;
							(file.asset as VideoVO).url = file.url;
							break;
					}
				}
			}
			clear(false);
			removeListeners();
			isLoading = false;
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.FILE_COMPLETE));
		}

		private function onError(event : Event) : void {
			if (event is ErrorEvent) {
				errors.push((event as ErrorEvent).text);
			}else if (event is NetStatusEvent) {
				errors.push((event as NetStatusEvent).info.code);
			}
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.FILE_ERROR));
			dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.FILE_COMPLETE));
			
			loader.dispatchEvent(new Event(Event.COMPLETE, true, true));
			isLoading = false;
		}

		
		private function getLoader() : * {
			var result : *;
			if (file == null)return null;
			if (file.type == null) return null;
			switch (file.type) {
				case File.CSS_FILE :
				case File.XML_FILE :
					result = new URLLoader();
					break;
				case File.VIDEO_FILE :
					var connection : NetConnection = new NetConnection();
					connection.connect(null);
					result = new NetStream(connection);
					
					var customClient : Object = new Object();
					customClient.aloader = this;
					customClient.file = file;
					customClient.onCuePoint = function(...args):void {
					};
					customClient.onMetaData = function(obj : Object):void {
						var f : File = this.file;
						f.asset.metaData = new MetaDataVO(obj);
						f.width = f.asset.metaData.width;
						f.height = f.asset.metaData.height;
						
						if (this.aloader.completeOnMetaData) {
							this.aloader.completeOnMetaData = false;
							this.aloader.onFileComplete(new Event(Event.COMPLETE));
						}
					};
					customClient.onPlayStatus = function(...args):void {
					};
					result.client = customClient;
					(file.asset as VideoVO).netConnection = connection;
					break;
				case File.TEXT_FILE :
					result = new URLLoader();
					result.dataFormat = URLLoaderDataFormat.VARIABLES;
					break;
				case File.SOUND_FILE :
					result = new Sound();
					break;
				case File.SWF_FILE :
				case File.IMAGE_FILE :
					result = new Loader();
					break;
			}
			return result;
		}
	}
}
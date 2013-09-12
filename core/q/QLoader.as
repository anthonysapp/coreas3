package core.q {

	import core.q.events.QEvent;
	import core.q.events.AssetLoaderEvent;
	import core.q.File;

	import flash.utils.Timer;
	import flash.events.EventDispatcher;

	/**
	 * @author anthonysapp
	 */
	public class QLoader extends EventDispatcher {
		private static const DEFAULT_ID : String = 'QLoader';
		//
		public var numberOfFiles : int = 0;
		public var id : String = QLoader.DEFAULT_ID;
		//
		private var a1 : AssetLoader;
		private var a2 : AssetLoader;
		private var a1Total : Number = 0;
		private var a2Total : Number = 0;

		private var timer : Timer;
		private var errors : Array;

		private var increment : int;
		private var loadedFiles : int = 0;
		private var totalFiles : int;

		private var useTimer : Boolean = false;
		private var multi : Boolean = true;

		private var qPercent : Number;

		private var qBytes : uint;
		private var qTotal : uint;

		private var filePercent : Number;
		private var fileBytes : uint;
		private var fileTotal : uint;

		private var currentTotal : int;

		private var loadArray : Array;

		public var files : Array;
		public var isLoading : Boolean = false;

		/*
		 * variables instantiated in constructor
		 */

		public function QLoader(timed : Boolean = false, useMultipleLoaders : Boolean = true) {
			useTimer = timed;
			multi = useMultipleLoaders;
			//
		}

		public function loadQ() : void {
			errors = new Array();
			if (loadArray == null || loadArray.length == 0) {
				onQComplete(null);
				return;
			}
			currentTotal = 0;
			increment = 0;
			filePercent = 0;
			qPercent = 0;
			
			a1Total = a2Total = 0;
			
			loadArray.sortOn('loadIndex', Array.NUMERIC);
			
			qTotal = getWeight();
			
			a1 = new AssetLoader();
			a1.id = 'a1';
			addAssetLoaderListeners(a1);
			
			if (loadArray.length > 1 && multi) {
			
				a2 = new AssetLoader();
				a2.id = 'a2';
				addAssetLoaderListeners(a2);
			}
			startLoad();
		}

		private function startLoad() : void {
			if (useTimer) {
				timer = new Timer(1);
				timer.start();
			}
			isLoading = true;
			totalFiles = loadArray.length;
			a1.loadFile(loadArray[0]); 
			if (loadArray.length <= 1 || multi == false)return;
			a2.loadFile(loadArray[1]);
		}

		public function clear(removeFilesFromLibrary : Boolean = false) : void {
			if (timer != null) {
				timer.stop();
				timer = null;
			}
			a1 = null;
			a2 = null;
			
			if (files != null && removeFilesFromLibrary) {
				for (var i : int = 0;i < files.length;i++) {
					QLibrary.removeFileById((files[i] as File).id);
				}
				try {
					a1.clear();
				}catch (e : *) {
				}
				try {
					a2.clear();
				}catch (e : *) {
				}
			}
			
			files = null;
			loadArray = null;
			isLoading = false;
		}

		private function addAssetLoaderListeners(aLoader : AssetLoader) : void {
			aLoader.addEventListener(AssetLoaderEvent.FILE_START, onStart);
			aLoader.addEventListener(AssetLoaderEvent.FILE_PROGRESS, onFileProgress);
			aLoader.addEventListener(AssetLoaderEvent.FILE_COMPLETE, onFileComplete);
			aLoader.addEventListener(AssetLoaderEvent.FILE_ERROR, onErrorHandler);
		}

		private function onStart(event : AssetLoaderEvent) : void {
			var aLoader : AssetLoader = event.target as AssetLoader;
			if (increment == 0) {
				increment++;
				dispatchEvent(new QEvent(QEvent.Q_START, id, qPercent, qBytes, qTotal, filePercent, fileBytes, fileTotal, aLoader.file));
			}
			dispatchEvent(new QEvent(QEvent.FILE_START, id, qPercent, qBytes, qTotal, filePercent, fileBytes, fileTotal, aLoader.file));
		}

		private function onFileProgress(event : AssetLoaderEvent) : void {
			var aLoader : AssetLoader = event.target as AssetLoader;
			if (a2 == null) {
				qBytes = currentTotal + a1.weightLoaded;
			} else {
				qBytes = currentTotal + a1.weightLoaded + a2.weightLoaded;
			}
			qPercent = qBytes / qTotal * 100;
			
			filePercent = Math.floor(aLoader.weightLoaded / aLoader.file.weight * 100);
			
			dispatchEvent(new QEvent(QEvent.FILE_PROGRESS, id, qPercent, qBytes, qTotal, filePercent, fileBytes, fileTotal, aLoader.file));		
			dispatchEvent(new QEvent(QEvent.Q_PROGRESS, id, qPercent, qBytes, qTotal, filePercent, fileBytes, fileTotal, aLoader.file));
		}

		private function onFileComplete(event : AssetLoaderEvent) : void {
			var aLoader : AssetLoader = event.target as AssetLoader;
			
			if (aLoader == a1)a1Total += aLoader.weightLoaded;
			if (aLoader == a2)a2Total += aLoader.weightLoaded;
			QLibrary.addFile(aLoader.file);
			
			loadArray.splice(findFile(aLoader.file.url), 1);
			
			dispatchEvent(new QEvent(QEvent.FILE_COMPLETE, id, qPercent, qBytes, qTotal, filePercent, fileBytes, fileTotal, aLoader.file, increment));
			aLoader.weightLoaded = 0;
			loadedFiles++;
			
			if (loadArray == null || loadArray.length == 0) {
				if (timer != null) {
					timer.stop();
				}
				if (aLoader == a1 ) {
					if (a2 != null)
					if (a2.isLoading)return;
				}else if (aLoader == a2) {
					if (a1.isLoading)return;
				}
				onQComplete(aLoader);
			} else {
				currentTotal += aLoader.file.weight;
				if (multi) {
					var otherLoader : AssetLoader = aLoader == a1 && a2 != null ? a2 : a1;
				
					if (otherLoader.file == null) {
						aLoader.loadFile(loadArray[0]);
					}else if (otherLoader.file.url == loadArray[0].url) {
						if (loadArray[1] != null)aLoader.loadFile(loadArray[1]);
					} else {
						aLoader.loadFile(loadArray[0]);
					}
				} else {
					aLoader = a1;
					a1.loadFile(loadArray[0]);	
				}
			}
		}

		private function findFile(url : String) : * {
			for ( var i : int = 0;i < loadArray.length;i++) {
				if (loadArray[i].url == url)return i;
			}
		}

		private function onQComplete(aLoader : AssetLoader = null) : void {
			if (errors.length > 0) {
				dispatchEvent(new QEvent(QEvent.Q_ERROR, id, 0, timer == null ? -1 : timer.currentCount, 0, 0, 0, 0, null, -1, 0, '\n++ QLoader Errors: \n- ' + errors.join('\n- ') + '\n++\n'));
			}
			isLoading = false;
			dispatchEvent(new QEvent(QEvent.Q_PROGRESS, id, 100, qBytes, qTotal, filePercent, fileBytes, fileTotal, aLoader == null ? null : aLoader.file));
			dispatchEvent(new QEvent(QEvent.Q_COMPLETE, id, 100, qBytes, qTotal, filePercent, fileBytes, fileTotal, aLoader == null ? null : aLoader.file, increment, timer == null ? -1 : timer.currentCount));
		}

		private function onErrorHandler(event : AssetLoaderEvent) : void {
			var aLoader : AssetLoader = event.target as AssetLoader;
			for (var i : Number = 0;i < aLoader.errors.length;i++) {
				errors.push(aLoader.errors[i]);
			}
			//dispatchEvent(new QEvent(QEvent.Q_ERROR, id, qPercent, qBytes, qTotal, filePercent, fileBytes, fileTotal, aLoader.file, increment, timer != null ? timer.currentCount : -1, 'file load error: could not load the file: ' + aLoader.file.url));
		}

		public function addFile(fileToAdd : File) : void {
			if (loadArray == null) { 
				loadArray = new Array();
				files = new Array();
			}
			if (fileToAdd.isValid == false) {
				fileToAdd = null;
				return;
			}
			loadArray.push(fileToAdd);
			files.push(fileToAdd);
			
			numberOfFiles = files.length;
		}

		public function hasFiles() : Boolean {
			return numberOfFiles > 0;
		}

		private function getWeight() : Number {
			var result : int = 0;
			for (var i:int = 0; i < loadArray.length; i ++ ) {
				var f:File = loadArray[i]; 
				result += f.weight;
			}
			return result;
		}

		public function addFiles(filesToAdd : Array) : void {
			for each (var file:File in filesToAdd) {
				addFile(file);
			}
		}
	}
}

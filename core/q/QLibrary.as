package core.q {

	import flash.utils.Dictionary;

	import core.q.File;	

	import flash.events.EventDispatcher;	

	/**
	 * Static class to store loaded files (as <a href=q/File.html>File</a> Objects)
	 * @author Sapp
	 * @version 1
	 */
	public class QLibrary {
		private static var files : Dictionary;
		protected static var disp : EventDispatcher;
		private static var error : String;

		public static function addEventListener(...p_args : Array) : void {
			if (disp == null) { 
				disp = new EventDispatcher(); 
			}	
			disp.addEventListener.apply(null, p_args);
		}

		public static function removeEventListener(...p_args : Array) : void {
			if (disp == null) { 
				return; 
			}
			disp.removeEventListener.apply(null, p_args);
		}

		public static function dispatchEvent(...p_args : Array) : void {
			if (disp == null) { 
				return; 
			}
			disp.dispatchEvent.apply(null, p_args);
		}

		/**
		 * adds a file to the QLibrary
		 * @param value String or Object
		 * @return the added <a href=q/File.html>File</a>
		 */
		public static function addFile(fileToAdd : File) : File {
			if (fileToAdd == null)return null;
			if (files == null ) {
				files = new Dictionary(true);
			}
			files[fileToAdd.id] = fileToAdd;
			return fileToAdd;
		}

		/**
		 * adds multiple files to the QLibrary
		 * @param array the array of <a href=q/File.html>File</a> objects or file names to be added
		 */
		public static function addFiles(array : Array) : void {
			for (var i : Number = 0;i < array.length;i++) {
				addFile(array[i]);
			}
		}

		/**
		 * @param substring the string to search all file names for
		 * @return an array of <a href=q/File.html>Files</a> whose names include the search string
		 */
		public static function getFilesBySubstring(substring : String) : Array {
			var array : Array = new Array();
			
			for each (var file:File  in files) {
				if (file.url.indexOf(substring) != -1) {
					array.push(file);
				}
			}
			return array;
		}

		/**
		 * @param extension the file extension to search for in the QLibrary's files
		 * @return an array of <a href=q/File.html>Files</a> whose extensions match the search extension
		 */
		public static function getFilesByExtension(extension : String) : Array {
			var array : Array = new Array();
			for each (var file:File in files) {
				if (file.extension == extension) {
					array.push(file);
				}
			}
			return array;
		}

		/**
		 * @param type the type of file to search for in the QLibrary's files (should be "data", "image", or "swf")
		 * @return an array of <a href=q/File.html>Files</a> whose types match the search type
		 */
		public static function getFilesByType(type : String = "") : Array {
			var array : Array = new Array();
			for each (var file:File in files) {
				if (file.type == type) {
					array.push(file);
				}
			}
			return array;
		}

		/**
		 * @param id the id to search for in the QLibrary's files
		 * @return an array of <a href=q/File.html>Files</a> whose ids match the search id
		 * @example var q:QLoader = new QLoader(true, true);<br/>
		 * q.addEventListener (QEvent.Q_COMPLETE, qCompleteHandler);<br/>
		 * q.files = [{url:'navimage1.jpg', target:new Sprite(), id:'nav'}, {url:'navimage2.jpg', target:new Sprite(), id:'nav'},{url:'navimage2.jpg', target:new Sprite(), id:'nav'}];<br/>
		 * function qCompleteHandler(e:QEvent):void{<br/>
		 * var arr:Array = QLibrary.getFilesById('nav');<br/>
		 * }
		 * 
		 */
		public static function getFilesById(id : *) : Array {
			var array : Array = new Array();
			for each (var file:File in files) {
				if (file.id == id) {
					array.push(file);
				}
			}
			return array;
		}

		public static function getFileById(id : String) : File {
			if (files == null) return null;
			return files[id];
		}

		/**
		 * @param filename the file name to search for in the QLibrary's files
		 * @return a single <a href=q/File.html>File</a> whose name matches the search filename
		 */
		public static function getFileByName(filename : String) : File {
			//trace ('searching for fileName: ' + filename);
			if (files == null) return null;
			var fileToReturn : File = null;
			for each (var file:File in files) {
				if (fileToReturn != null) break;
				if (file.url == filename) {			
					fileToReturn = file;
				}
			}
			return fileToReturn;
		}

		/**
		 * @param value the number of the file to be returned
		 * @return a single <a href=q/File.html>File</a> whose number matches the value 
		 */
		public static function getFile(value : File) : File {
			var selectedFile : File;
			try {
				selectedFile = files[value.url];
				if (selectedFile == null) {
					throw (new Error('file not found'));	
				}
			}
			catch (e : Error) {
				error = e.message;
				//MonsterDebugger.trace('QLibrary:: ', 'QLibrary error: ' + error);
				selectedFile = null;
			}finally {
				return selectedFile;
			}
		}

		/**
		 * @return all the <a href=q/File.html>Files</a> in the QLibrary
		 */
		public static function getFiles() : Array {
			var array : Array = new Array();
			for each (var file:File in files) {
				array.push(file);
			}
			return array;
		}

		/**
		 * @return all the file names of the <a href=q/File.html>Files</a> in the QLibrary
		 */
		public static function getFileNames() : Array {
			var arr : Array = new Array();
			for each (var file:File in files) {
				arr.push(file.url);
			}
			return arr;
		}

		public static function traceFiles() : void {
			for each (var file:File in files) {
				//MonsterDebugger.trace('QLibrary file:: ', file);
				trace('QLibrary file:: ', file);
			}
		}

		/**
		 * @param filename the url of the file to be removed from the QLibrary
		 */
		public static function removeFileByName(filename : String) : void {
			for each (var file:File in files) {
				if (file.url == filename) {
					removeFile(file.id);
				}
			}
		}

		private static function removeFile(id : String) : void {
			if (files == null)return;
			if (files[id] == null)return;
			File(files[id]).destroy();
			delete files[id];
		}

		/**
		 * @param filename the id of the file to be removed from the QLibrary
		 */
		public static function removeFileById(id : String) : void {
			removeFile(id);
		}

		/**
		 * clears all the files in the QLibrary
		 */
		public static function clear() : void {
			for (var f in files){
				delete files[f];
			}
		}

		public static function get numFiles() : int {
			if (files == null)return 0;
			var result : int = 0;
			for each (var file:File in files) {
				result++;
			}
			return result;
		}
	}
}

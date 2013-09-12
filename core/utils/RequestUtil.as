package core.utils {
	import core.events.RequestEvent;
	import com.adobe.net.DynamicURLLoader;

	import flash.events.ProgressEvent;	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;	

	/**
	 * @author Sapp, Joseph
	 * @version 1
	 */
	public class RequestUtil {
		// **********************************************
		// Private static variables
		private static  var disp : EventDispatcher;
		private static  var gateway : String;
		private static  var method : String;
		private static  var variables : URLVariables;

		// **********************************************
		// Custom load function
		/**
		 * sends a new request
		 * @param gatewayURL the url to send the request
		 * @param urlVariablesInput string or URLVariables - default: empty string
		 * @param loaderID a unique id for the load - when the request is finished, a new RequestEvent is dispatched that holds this id - useful if you want to handle all requests in one handler
		 * @param methodType "POST" or "GET" - default: "POST"
		 * @param awaitResult whether the Requester will return a result - default: true
		 */
		public static function load(gatewayURL : String = "",urlVariablesInput : * = null,loaderID : * = "",methodType : String = 'POST', awaitResult : Boolean = true) : void {
			
			// **********************************************
			// Set gateway
			gateway = gatewayURL;
			if (gateway == '') {
				trace("Requester Error: You Must Specify an gateway");
				return;
			}

			// **********************************************
			// Set variables
			if (urlVariablesInput != null) {
				if (typeof urlVariablesInput == 'string') {
					variables = new URLVariables(urlVariablesInput);
				} else if (urlVariablesInput is URLVariables) {
					variables = urlVariablesInput as URLVariables;
				}
			}else{
				variables = null;
			}

			// **********************************************
			// Set method
			method = methodType.toUpperCase();
			if (method != URLRequestMethod.POST && method != URLRequestMethod.GET) {
				trace("Requester Error: incorrect method supplied for content load.");
				return;
			}
			
			// **********************************************
			// Prepare request
			var request : URLRequest = new URLRequest(gateway);
			request.data = variables;
			request.method = method;
			
			// **********************************************
			// Send request			
			var loader : DynamicURLLoader = new DynamicURLLoader();
			loader['id'] = loaderID;
			
			loader.addEventListener(Event.OPEN, openHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			if (awaitResult) {
				loader.addEventListener(Event.COMPLETE, processRequest);
				loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			}			
			//trace ('sending request: ' + request.url);
			loader.load(request);
		}		

		public static function sendAndLoadImage(gatewayURL : String, urlVariablesInput : *, header : URLRequestHeader = null, jpgStream : ByteArray = null, loaderID : * = 'sendAndLoadImage', methodType : String = 'post', awaitResult : Boolean = true) : void {
			// **********************************************
			// Set gateway
			gateway = gatewayURL;
			if (gateway == '') {
				trace("Requester Error: You Must Specify an gateway");
				return;
			}

			// **********************************************
			// Set variables
			if (typeof urlVariablesInput == 'string') {
				variables = new URLVariables(urlVariablesInput);
			} else if (urlVariablesInput is URLVariables) {
				variables = urlVariablesInput as URLVariables;
			}

			// **********************************************
			// Set method
			method = methodType.toUpperCase();
			if (method != URLRequestMethod.POST && method != URLRequestMethod.GET) {
				trace("Requester Error: incorrect method supplied for content load.");
				return;
			}
			
			// **********************************************
			// Prepare request
			var request : URLRequest = new URLRequest(gateway + buildVariablesString(variables));
			if (header != null) {
				request.requestHeaders.push(header);
			}
			request.data = jpgStream;
			request.method = method;
			
			// **********************************************
			// Send request			
			var loader : DynamicURLLoader = new DynamicURLLoader();
			loader['id'] = loaderID;
			
			loader.addEventListener(Event.OPEN, openHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			if (awaitResult) {
				loader.addEventListener(Event.COMPLETE, processRequest);
				loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			}			
			
			loader.load(request);
		}

		private static function buildVariablesString(variables : URLVariables) : String {
			var str : String = '?';
			var count : int = 0;
			for (var variable:* in variables) {
				if (count > 0) {
					str += '&';
				}
				str += variable + '=' + variables[variable];
				count++;
			}
			//trace ('string is: ' + str);
			return str;
		}

		public static function send(gatewayURL : String = "",urlVariablesInput : * = null,loaderID : * = "",methodType : String = 'POST') : void {
			load(gatewayURL, urlVariablesInput, loaderID, methodType, false);
		}

		private static function openHandler(event : Event) : void {
			dispatchEvent(new RequestEvent('open', (event.target as DynamicURLLoader)['id']));
		}

		private static function progressHandler(event : ProgressEvent) : void {
			dispatchEvent(new RequestEvent('progress', (event.target as DynamicURLLoader)['id'], null, event.bytesLoaded, event.bytesTotal));
		}

		// **********************************************
		// Process the loader request
		private static function processRequest(event : Event) : void {
			
			var dLoader : DynamicURLLoader = event.target as DynamicURLLoader;
			
			dLoader.removeEventListener(Event.COMPLETE, processRequest);
			dLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			dLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			if (dLoader.data) {
				dispatchEvent(new RequestEvent('complete', dLoader['id'], dLoader.data, dLoader.bytesLoaded, dLoader.bytesTotal));
			}
		}

		// **********************************************
		// Handle input/output errors
		private static function onIOError(error : IOErrorEvent) : void {
			dispatchEvent(new RequestEvent('error', (error.target as DynamicURLLoader)['id'], null, 0, 0, '+-- Requester Error --+ ' + error.text + '\n'));
		}

		// **********************************************
		// Handle security errors
		private static function onSecurityError(error : SecurityErrorEvent) : void {
			dispatchEvent(new RequestEvent('error', (error.target as DynamicURLLoader)['id'], null, 0, 0, error.text));
		}

		// **********************************************
		// Add event listener
		public static function addEventListener(... p_args : Array) : void {
			if (disp == null) {
				disp = new EventDispatcher  ;
			}
			disp.addEventListener.apply(null, p_args);
		}

		// **********************************************
		// Remove event listener
		public static function removeEventListener(... p_args : Array) : void {
			if (disp == null) {
				return;
			}
			disp.removeEventListener.apply(null, p_args);
		}

		// **********************************************
		// Dispatch event
		private static function dispatchEvent(... p_args : Array) : void {
			if (disp == null) {
				return;
			}
			disp.dispatchEvent.apply(null, p_args);
		}
	}
}


package core {

	/**
	 * Traces object properties
	 * <br/><b>Note: </b> has been tested with Object, Array, and URLVariables so far
	 */
	public class ObjectTracer {
		/**
		 * @param inputObject the object to be traced
		 * @param generationNum the generation of the trace (how many levels into the object are we?) <b>Note: </b> not necessary to set this
		 */
		public static function traceObj(inputObject : Object, generationNum : Number = 0) : void {
			if (typeof (inputObject) != 'object') {
				trace('ObjectTracer error: input value is not an object');
				return;
			}
			var obj : Object = inputObject as Object;
			var gen : Number = Math.round(generationNum);
	
			var tab_str : String = "";
			for (var j : Number = 0;j < gen; j++) {
				tab_str += "\t";
			}
			if (gen == 0) {
				trace("+");
			}
			for (var i:* in obj) {
				if (typeof (obj[i]) == 'object') {
					trace("|" + tab_str + i + ":");
					ObjectTracer.traceObj(obj[i], gen + 1);
				} else {
					var str : String = '|';
					str += tab_str;
					str += i;
					str += ': ';
					str += obj[i];
					trace(str);
				}
			}
			if (gen == 0) {
				trace("+");
			}
		}
	}
}

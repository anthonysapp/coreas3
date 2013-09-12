package core.utils {

	/**
	 * @author anthonysapp
	 */
	public class ArrayUtil {
		public static function shuffleArray(arrayToShuffle : Array) : void {
			var _length : int = arrayToShuffle.length, rn : int, it : int;
			var arr2 : Array = [];
			while (arrayToShuffle.length > 0) {
				arr2.push(arrayToShuffle.splice(Math.round(Math.random() * (arrayToShuffle.length - 1)), 1)[0]);
			}
			for (it = 0 ;it < _length;it++) {
				arrayToShuffle.push(arr2[it]);
			}
		};
	}
}

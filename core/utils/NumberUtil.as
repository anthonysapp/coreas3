package core.utils {

	/**
	 * @author anthonysapp
	 */
	public class NumberUtil {
		public static function getTwoDigitString(value : Number) : String {
			if (value >= 10)return Math.floor(value).toString();
			var str : String = '0';
			str += Math.floor(value).toString();
			
			return str;
		}

		public static function formatNumber(value : Number, delimeter:String = ',') : String {
			var numString : String = value.toString()
			var result : String = '';

			while (numString.length > 3) {
				var chunk : String = numString.substr(-3);
				numString = numString.substr(0, numString.length - 3);
				result = delimeter + chunk + result;
			}

			if (numString.length > 0) {
				result = numString + result;
			}

			return result;
		}
	}
}

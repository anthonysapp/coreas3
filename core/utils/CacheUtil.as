package core.utils {

	/**
	 * @author anthonysapp
	 */
	public class CacheUtil {
		public static var isOnline : Boolean = false;
		public static var version : String = null;

		public static function create(url : String) : String {
			if (!isOnline) {
				return url;
			}
			var d : Date = new Date();
			var nc : String = version == null ? "nocache=" + d.getTime() : "version=" + version;
			if (url.indexOf("?") > -1) return url + "&" + nc;
			var result : String = url + "?" + nc;
			return result;
		}
	}
}

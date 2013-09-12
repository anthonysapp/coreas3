package core.utils {

	/**
	 * @author anthonysapp
	 */
	public class ColorUtil {
		public static function convertColor( color : Object, hasAlpha : Boolean = false ) : uint {
			if( color is String ) {
				var pattern : RegExp = /#/;
				color = uint(color.toString().replace(pattern, "0x"));
			}
			else if( !( color is Number ) ) {
				color = Number(color);
			}
			var max : Number = ( hasAlpha ) ? 0xFFFFFFFF : 0xFFFFFF;
			return uint(Math.min(Math.max(Number(color), 0), max));
		}
	}
}

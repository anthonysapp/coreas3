package core.utils {
	import flash.text.Font;
	import flash.utils.getDefinitionByName;

	/**
	 * @author anthonysapp
	 */
	public class FontUtil {
		public static var fontList:Array;
		
		public static function getFont(value : String, registerFont : Boolean = true) : Font {
			try {
				var C : Class = getDefinitionByName(value) as Class;
				if (registerFont) {
					Font.registerFont(C);
					fontList = Font.enumerateFonts();
				}
			}catch (e : *) {
				return null;
			}
			return new C();
		}

		public static function getFontClass(value : String) : Class {
			var C : Class = getDefinitionByName(value) as Class;
			return C;
		}

		public static function getEmbeddedFontNames() : String {
			var str : String = '------- Embedded Fonts ---------\n';
			for each (var f:Font in Font.enumerateFonts()) {
				str += f.fontName + '\n';	
			}
			str += '--------------------------------\n';
			return str;
		}

		public static function isFontEmbedded(fontName : String) : Boolean {
			for each (var f:Font in Font.enumerateFonts()) {
				if (f.fontName == fontName)return true;
			}
			return false;
		}
	}
}

package core.display {
	import flash.text.StyleSheet;

	/**
	 * @author anthonysapp
	 */
	public interface ITextDisplay {
		function get autoSize() : String ;

		function set autoSize(autoSize : String) : void ;

		function get multiline() : Boolean ;

		function set multiline(multiline : Boolean) : void ;

		function get text() : String ;

		function set text(text : String) : void ;

		function get html() : Boolean ;

		function set html(value : Boolean) : void ;

		function get styleSheet() : StyleSheet ;

		function set styleSheet(value : StyleSheet) : void ;

		function get maxLines() : int ;

		function set maxLines(value : int) : void ;
	}
}

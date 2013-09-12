package core.forms {
	import flash.text.TextFormat;

	/**
	 * @author ted
	 */
	public interface IErrorDisplay {
		
		function showError() : void;
		function hideError(): void;
		function set errorMessage(_eMessage:String) : void;
		function set textFormat(_format:TextFormat) : void;
	}
}

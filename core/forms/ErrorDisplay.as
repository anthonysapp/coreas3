package core.forms {
	import flash.text.TextFormat;
	import flash.text.TextField;	
	import flash.display.MovieClip;
	
	import core.forms.IErrorDisplay;
	
	/**
	 * @author ted
	 */
	public class ErrorDisplay extends MovieClip implements IErrorDisplay {
		
		public var error_txt : TextField;
		
		private var _errorMessage : String;
		
		private var _textFormat : TextFormat;
		
		public function ErrorDisplay() {
			for ( var i : uint = 0; i < this.numChildren; i++ ){
				if (this.getChildAt(i) is TextField){
					error_txt = TextField(this.getChildAt(i));	
				}
			}
			error_txt.text = 'working!';
		}

		public function showError() : void {
			error_txt.htmlText = _errorMessage;
			if ( _textFormat != null ){
				error_txt.setTextFormat(_textFormat);
				if ( _textFormat.font != null )error_txt.embedFonts = true;
			}
			
		}

		public function hideError() : void {
			error_txt.text = '';
		}
		
		public function set errorMessage(_eMessage : String) : void {
			_errorMessage = _eMessage;
			showError();
		}
		
		public function set textFormat(_format : TextFormat) : void {
			_textFormat = _format;
			
		}
	}
}

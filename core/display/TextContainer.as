package core.display {
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextField;	
	import flash.display.MovieClip;

	/**
	 * @author anthonysapp
	 */
	public class TextContainer extends MovieClip {
		public var field : TextField;
		protected var _autoSize : String = TextFieldAutoSize.LEFT;
		protected var _multiline : Boolean = true;
		protected var _text : String;
		protected var _html : Boolean = true;
		protected var _textFormat : TextFormat;
		protected var _styleSheet : StyleSheet;
		protected var _maxLines : int = 0;
		protected var _setup : Boolean = false;
		protected var _maxHeight : Number = -1;
		protected var _hasChangedSize : Boolean = false;
		private var _originalTextFormatSize : Number;		private var _prevNumLines : Number;
		private var _firstRun : Boolean = true;

		
		public function TextContainer() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		protected function onAddedToStage(event : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			setup();
		}

		protected function setup() : void {
			if (_setup)return;
			var index : int = this.numChildren;
			while (index--) {
				if (getChildAt(index) is TextField) {
					field = getChildAt(index) as TextField;
					break;
				}
			}
			_autoSize = field.autoSize == "none" ? TextFieldAutoSize.LEFT : field.autoSize;
			
			_multiline = field.multiline;
			_textFormat = field.getTextFormat();
			_originalTextFormatSize = Number(_textFormat.size);
			_prevNumLines = field.numLines;
			_text = field.text;
			_setup = true;
		}

		protected function setText() : void {
			if (_text == null)return;
			_textFormat = field.getTextFormat();
			
			
			field.multiline = _multiline;
			field.autoSize = _autoSize;
			
			if (_styleSheet != null) field.styleSheet = _styleSheet;
			field.htmlText = _text;
			
			
			if (field.styleSheet == null) {
				field.setTextFormat(_textFormat);
				if (_firstRun || field.numLines > _prevNumLines) {
					if (_maxHeight > 0) {
						checkMaxHeight();
					} else {
						checkMaxLines();
					}
				}else if(field.numLines < _prevNumLines) {
					if (_maxHeight > 0) {
						adjustHeight();
					}
				}
			}
			_firstRun = false;
			_prevNumLines = field.numLines;
			field.mouseWheelEnabled = false;
			/*if (html) { 
				field.htmlText = _text; 
			} else {
				field.text = _text;
			}*/
		}

		private function checkMaxHeight() : void {
			if (height > _maxHeight) {
				_hasChangedSize = true;
				_textFormat.size = Number(_textFormat.size) - 1;
				field.setTextFormat(_textFormat);
				checkMaxHeight();
			}
		}

		private function adjustHeight() : void {
			if (_hasChangedSize && ((Number(_textFormat.size) + 1) <= _originalTextFormatSize)) {
				_textFormat.size = Number(_textFormat.size) + 1;
				field.setTextFormat(_textFormat);
				if (Number(_textFormat.size) == _originalTextFormatSize) {
					_hasChangedSize = false;
					checkMaxHeight();
					return;
				}
				adjustHeight();
			}
		}

		private function checkMaxLines() : void {
			if (_maxLines == 0)return;
			if (field.numLines > _maxLines) {
				_textFormat.size = Number(_textFormat.size) - 1;
				field.setTextFormat(_textFormat);
				checkMaxLines();
			}
		}

		public function get autoSize() : String {
			return _autoSize;
		}

		public function set autoSize(autoSize : String) : void {
			_autoSize = autoSize;
			setText();
		}

		public function get multiline() : Boolean {
			return _multiline;
		}

		public function set multiline(multiline : Boolean) : void {
			_multiline = multiline;
		}

		public function get text() : String {
			return _text;
		}

		public function set text(text : String) : void {
			_text = text;
			setText();
		}

		public function get html() : Boolean {
			return _html;
		}

		public function set html(value : Boolean) : void {
			_html = value;
		}

		public function get styleSheet() : StyleSheet {
			return _styleSheet;
		}

		public function set styleSheet(styleSheet : StyleSheet) : void {
			_styleSheet = styleSheet;
		}

		public function get maxLines() : int {
			return _maxLines;
		}

		public function set maxLines(value : int) : void {
			_maxLines = value;
		}

		public function set maxHeight(value : Number) : void {
			_maxHeight = value;
		}
	}
}

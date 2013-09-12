package core.display {
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;

	import core.display.ITextDisplay;
	import core.display.TextContainer;
	import core.display.StateSprite;

	/**
	 * @author anthonysapp
	 */
	public class TextButton extends StateClip implements ITextDisplay {
		protected var _textContainer : TextContainer;

		public function TextButton() {
			super();
		}

		override public function setup() : void {
			buttonMode = true;
			mouseChildren = false;
			addListeners();	
		}

		protected function addListeners() : void {
			addEventListener(MouseEvent.ROLL_OUT, _onRollOut);			addEventListener(MouseEvent.ROLL_OVER, _onRollOver);			addEventListener(MouseEvent.ROLL_OUT, _onClick);
		}

		protected function removeListeners() : void {
			removeEventListener(MouseEvent.ROLL_OUT, _onRollOut);
			removeEventListener(MouseEvent.ROLL_OVER, _onRollOver);
			removeEventListener(MouseEvent.ROLL_OUT, _onClick);
		}

		protected function _onClick(event : MouseEvent) : void {
			state = 'click';
		}

		protected function _onRollOver(event : MouseEvent) : void {
			state = 'rollover';
		}

		protected function _onRollOut(event : MouseEvent) : void {
			state = 'rollout';
		}

		protected function get textContainer() : TextContainer {
			if (_textContainer == null)return getTextContainer();
			return _textContainer;
		}

		protected function getTextContainer() : TextContainer {
			var index : int = numChildren;
			var child : *;
			while (index-- ) {
				child = getChildAt(index);
				if (child is TextContainer) {
					_textContainer = child;
					return _textContainer;
				}
			}
			return null;
		}

		public function get autoSize() : String {
			return textContainer.autoSize;
		}

		public function get multiline() : Boolean {
			return textContainer.multiline;
		}

		public function get text() : String {
			return textContainer.text;
		}

		public function get html() : Boolean {
			return textContainer.html;
		}

		public function get styleSheet() : StyleSheet {
			return textContainer.styleSheet;
		}

		public function get maxLines() : int {
			return textContainer.maxLines;
		}

		public function set maxLines(value : int) : void {
			textContainer.maxLines = value;
		}

		public function set autoSize(autoSize : String) : void {
			textContainer.autoSize = autoSize;
		}

		public function set multiline(multiline : Boolean) : void {
			textContainer.multiline = multiline;
		}

		public function set text(text : String) : void {
			textContainer.text = text;
		}

		public function set html(value : Boolean) : void {
			textContainer.html = value;
		}

		public function set styleSheet(value : StyleSheet) : void {
			textContainer.styleSheet = value;
		}
	}
}

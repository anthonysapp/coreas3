package core.utils {
	import flash.display.DisplayObject;	

	/**
	 * @author anthonysapp
	 */
	public class ResizeUtil {
		public static function checkSize(displayObject : DisplayObject,desiredWidth : *= null, desiredHeight : *= null) : Boolean {
			if (displayObject.width > desiredWidth || displayObject.height > desiredHeight) {
				
				resize(displayObject, desiredWidth, desiredHeight);
				return true;
			}
			if (displayObject.width < desiredWidth || displayObject.height < desiredHeight) {
				grow(displayObject, desiredWidth, desiredHeight);
				return true;
			}
			return false;
		}

		public static function resize(displayObject : DisplayObject,maxWidth : * = null, maxHeight : * = null) : void {
			var originalWidth : Number = displayObject.width;
			var originalHeight : Number = displayObject.height;
			
			if (originalHeight <= maxHeight && originalWidth <= maxWidth)return;
			if (maxWidth != null) {
				maxWidth = Number(maxWidth);
				if (displayObject.width > maxWidth) {
					while (displayObject.width > maxWidth) {
						
						displayObject.scaleX -= 0.001;
						displayObject.scaleY -= 0.001;
					}
					resize(displayObject, maxWidth, maxHeight);
				}
			}
			if (maxHeight != null) {
				maxHeight = Number(maxHeight);
				if (displayObject.height > maxHeight) {
					while (displayObject.height > maxHeight) {
						displayObject.scaleX -= 0.001;
						displayObject.scaleY -= 0.001;
					}
					resize(displayObject, maxWidth, maxHeight);
				}
			}
		}

		public static function grow(displayObject : DisplayObject,maxWidth : * = null, maxHeight : * = null) : void {
			var originalWidth : Number = displayObject.width;
			var originalHeight : Number = displayObject.height;
			
			if (originalHeight >= maxHeight && originalWidth >= maxWidth)return;
			if (maxWidth != null) {
				maxWidth = Number(maxWidth);
				if (displayObject.width < maxWidth) {
					while (displayObject.width < maxWidth) {
						displayObject.scaleX += 0.001;
						displayObject.scaleY += 0.001;
					}
					grow(displayObject, maxWidth, maxHeight);
				}
			}
			if (maxHeight != null) {
				maxHeight = Number(maxHeight);
				if (displayObject.height < maxHeight) {
					while (displayObject.height < maxHeight) {
						displayObject.scaleX += 0.001;
						displayObject.scaleY += 0.001;
					}
					grow(displayObject, maxWidth, maxHeight);
				}
			}
		}
	}
}

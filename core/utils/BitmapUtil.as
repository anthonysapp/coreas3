package core.utils {
	import flash.display.DisplayObjectContainer;

	import core.ObjectTracer;

	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.ColorTransform;	
	import flash.display.PixelSnapping;	
	import flash.geom.Matrix;	
	import flash.display.Sprite;	
	import flash.display.DisplayObject;	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	/**
	 * @author Sapp
	 */
	public class BitmapUtil {
		/**
		 * slices any DisplayObject into bitmap tiles and returns a container Sprite
		 * <br/>useful for when a loaded image is larger than the maximum BitmapData size (taller or wider than 2880 px)
		 * @param objectToSlice a DisplayObject you wish to slice
		 * @param tileHeight the height of each tile - default: 2880
		 * @param tileWidth the width of each tile - default: 2880
		 */
		public static function SliceDisplayObject(objectToSlice : DisplayObject,  tileWidth : Number = 2880, tileHeight : Number = 2880) : Sprite {
			if (objectToSlice == null) return null;
			var parentspr : Sprite = new Sprite();
			parentspr.addChild(objectToSlice);
			
			var spr : Sprite = new Sprite();
			
			var w : Number = objectToSlice.width;
			var h : Number = objectToSlice.height;
			
			var tw : Number = tileWidth;
			var th : Number = tileHeight;
		
			var cols : Number = Math.ceil(w / tw);
			var rows : Number = Math.ceil(h / th);

			var _x : Number;
			var _y : Number;
			for (var i : Number = 0;i < rows;i++) {
				for (var j : Number = 0;j < cols;j++) {
					_x = j * tw;
					_y = i * th;
					objectToSlice.x = -_x;
					objectToSlice.y = -_y;
					var bmd : BitmapData = new BitmapData(tw, th);
					bmd.draw(parentspr, null, null, null, new Rectangle(0, 0, tw, th), true);
					var bm : Bitmap = new Bitmap(bmd, 'auto', true);
					var ns : Sprite = new Sprite();
					ns.addChild(bm);
					ns.x = _x;
					ns.y = _y;
					spr.addChild(ns);
				}
			}
			parentspr.removeChild(objectToSlice);
			parentspr = null;
			return spr;
		}

		public static function makeBitmapData(displayObject : DisplayObject, transparent : Boolean = true) : BitmapData {
			var bounds : Rectangle = null;
			if (displayObject is DisplayObjectContainer) {
				var doc : DisplayObjectContainer = displayObject as DisplayObjectContainer;
				if (doc.getChildByName('drawingArea') != null) {
					bounds = new Rectangle (0,0,doc.getChildByName('drawingArea').width,doc.getChildByName('drawingArea').height);
					doc.getChildByName('drawingArea').visible = false;
				}
			}
			if  (bounds == null) bounds = displayObject.getBounds(displayObject)
			var bmd : BitmapData = new BitmapData(bounds.width, bounds.height, transparent, 0x00FFFFFF);
			bmd.draw(displayObject, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y), null, null, null, false);
			return bmd;
		}

		public static function makeBitmap(input : DisplayObject, transparent : Boolean = true, blendMode : String = null, pixelSnapping : String = 'auto',smoothing : Boolean = false) : Bitmap {
			var bounds : Rectangle = input.getBounds(input);
			var bmd : BitmapData = new BitmapData(bounds.width, bounds.height, transparent, 0x00FFFFFF);
			bmd.draw(input, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y), new ColorTransform(), blendMode, null, smoothing);
			var bmp : Bitmap = new Bitmap(bmd, pixelSnapping, smoothing);
			return bmp;
		}

		public static function scrollBitmap(bitmapData : BitmapData,scrollX : int,scrollY : int, doTrace : Boolean = false) : void {
			// wrap values
			bitmapData.lock();
			while(scrollX > bitmapData.width) scrollX -= bitmapData.width;
			while(scrollX < -bitmapData.width) scrollX += bitmapData.width;
			while(scrollY > bitmapData.height) scrollY -= bitmapData.height;
			while(scrollY < -bitmapData.height) scrollY += bitmapData.height;
    
			// the 4 edges of the bitmap
			var xPixels : int = Math.abs(scrollX), yPixels : int = Math.abs(scrollY);
			var rectR : Rectangle = new Rectangle(bitmapData.width - xPixels, 0, xPixels, bitmapData.height);
			var rectL : Rectangle = new Rectangle(0, 0, xPixels, bitmapData.height);
			var rectT : Rectangle = new Rectangle(0, 0, bitmapData.width, yPixels);
			var rectB : Rectangle = new Rectangle(0, bitmapData.height - yPixels, bitmapData.width, yPixels);
			var pointL : Point = new Point(0, 0);
			var pointR : Point = new Point(bitmapData.width - xPixels, 0);
			var pointT : Point = new Point(0, 0);
			var pointB : Point = new Point(0, bitmapData.height - yPixels);
    
			var tmp : BitmapData = new BitmapData(bitmapData.width, bitmapData.height, bitmapData.transparent, 0x000000);
    		
			// copy column, scroll, paste
			scrollX > 0 ? tmp.copyPixels(bitmapData, rectR, pointL) : tmp.copyPixels(bitmapData, rectL, pointR);
			bitmapData.scroll(scrollX, 0);
			scrollX > 0 ? bitmapData.copyPixels(tmp, rectL, pointL) : bitmapData.copyPixels(tmp, rectR, pointR);
    
			// copy row, scroll, paste
			scrollY > 0 ? tmp.copyPixels(bitmapData, rectB, pointT) : tmp.copyPixels(bitmapData, rectT, pointB);
			bitmapData.scroll(0, scrollY);
			scrollY > 0 ? bitmapData.copyPixels(tmp, rectT, pointT) : bitmapData.copyPixels(tmp, rectB, pointB);
			bitmapData.unlock();
			tmp.dispose();
			tmp = null;
		}

		public static function getCachedMovieClipObject(mc : MovieClip) : Object {
			var obj : Object = new Object();
			var dummy : Sprite = new Sprite();
			
			if (mc.parent == null) {
				dummy.addChild(mc);
			}
			var bmd : BitmapData;
			var num : uint = 1;
			var total : uint = mc.totalFrames;
			
			while (num <= total) {
				mc.stop();
				bmd = makeBitmapData(mc);
				if (mc.currentLabel == null || mc.currentLabel == '') {
					obj[mc.currentFrame] = bmd;
				} else {
					obj[mc.currentLabel] = bmd;
				}
				mc.nextFrame();
				num++;
			}
			return obj;
		}
	}
}

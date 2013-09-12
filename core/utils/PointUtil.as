package core.utils {

	import flash.display.DisplayObject;
	import flash.geom.Point;
	/**
	 * @author anthonysapp
	 */
	public class PointUtil {
		public static function localToLocal(from : DisplayObject, to : DisplayObject, origin : Point = null) : Point {
			var point : Point = origin == null ? new Point (0,0) : origin;
			var pt:Point = new Point (point.x, point.y);
			from.localToGlobal(pt);
			to.globalToLocal(pt);
			return pt;
		}
	}
}

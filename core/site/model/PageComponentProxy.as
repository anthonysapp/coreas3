package core.site.model {
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * @author anthonysapp
	 */
	public class PageComponentProxy extends Proxy {
		public function PageComponentProxy(proxyName : String = null, data : Object = null) {
			super(proxyName, data);
		}

		override public function setData( data : Object ) : void {
			this.data = parseData(data);
		}

		private function parseData(data : Object) : Object {
			var result : PageComponentVO = new PageComponentVO();
			var xml : XMLList = data as XMLList;
			result.id = xml.@id;
			result.name = xml.@name.toString() == '' ? result.id : xml.@name;
			result.parent = xml.@parent.toString() == '' ? 'site' : xml.@parent;
			result.container = xml.@container.toString() == '' ? null : xml.@container;
			result.content = xml.content;
			result.url = xml.@url;
			result.cache = xml.@cache != "false";
			return result;
		}
	}
}

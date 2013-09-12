package core.site.model {
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * @author anthonysapp
	 */
	public class SiteProxy extends Proxy {
		public static const NAME : String = "SiteProxy";

		public function SiteProxy() {
			super(NAME);
		}

		override public function setData(data : Object) : void {
			this.data = parseData(data);
		}

		private function parseData(data : Object) : Object {
			var svo : SiteVO = new SiteVO();
			var pvo : PageVO;
			
			for each(var pxml:XML in (data as XML)..page) {
				pvo = new PageVO();
				pvo.id = pxml.@id;
				pvo.name = pxml.@name.toString() == '' ? pvo.id : pxml.@name;
				pvo.title = pxml.@title;
				if (pvo.id != 'site')pvo.parent = pxml.@parent.toString() == '' ? 'site' : pxml.@parent.toString();
				pvo.url = pxml.@url;
				pvo.weight = int(pxml.@weight) > 0 ? int(pxml.@weight) : 1 ;
				pvo.cache = pxml.@cache != "false";
				pvo.container = pxml.@container.toString() == '' ? null : pxml.@container;
				pvo.sitemap = pxml.@sitemap.toString() != "false";
				pvo.assets = parseAssets(pvo, pxml.asset, true);
				pvo.components = pxml.component;
				pvo.content = pxml.content;
				pvo.isDefault = pxml.@default == "true";
				pvo.transition = pxml.@transition;
				pvo.active = pxml.@active;
				
				parsePage(pvo, data as XML);
				
				svo.pageMap[pvo.map] = pvo;
				svo.idMap[pvo.id] = pvo;
				svo.transitionMap[pvo.id] = pvo.transitionMap;
				svo.nameMap[pvo.name] = pvo;
			}
			return svo;
		}

		private function parseAssets(pvo : PageVO, assets : XMLList, addPageAsset : Boolean = false) : Array {
			var avo : SiteAssetVO;
			var result : Array = new Array();
			
			if (addPageAsset && pvo.id != 'site') {
				avo = new SiteAssetVO();
				avo.url = pvo.url;
				avo.id = pvo.id;
				avo.weight = pvo.weight;
				avo.cache = pvo.cache; 
				result.push(avo);
			}
			for each (var asset:XML in assets) {
				avo = new SiteAssetVO();
				avo.url = asset.@url.toString();
				avo.id = asset.@id.toString();
				avo.weight = int(asset.@weight) > 0 ? int(asset.@weight) : 1 ;
				avo.index = int(asset.@load_index);
				avo.cache = asset.@cache == "false" ? false : true; 
				avo.targetPercent = int(asset.@target_percent) < 100 ? int(asset.@target_percent) : 100 ;
				result.push(avo);
			}
			return result;
		}

		private function parsePage(pvo : PageVO, xml : XML) : void {
			var pageLevel : int = 0;
			var map : String = '';
			var mArr : Array = new Array();			var tArr : Array = new Array();
			var id : String = pvo.id;
			var node : XMLList = xml..page.(@id == id); 
			var pID : String = null; 
			mArr.push(pvo.name);
			tArr.push(node.@id);
			
			while (node.@id != 'site') {
				pageLevel++;
				pID = node.@parent.toString() == '' ? 'site' : node.@parent;
				node = xml..page.(@id == pID);
				if (node.@sitemap.toString() != "false") mArr.push(node.@name);
				tArr.push(node.@id.toString());
			}
			
			mArr.reverse();
			if (mArr[0].toString() == '')mArr.shift();
			map = mArr.join('/');
			if (tArr.length == 1)tArr = ['site'];
			pvo.map = map;
			pvo.transitionMap = tArr.reverse();
			pvo.level = pageLevel;
		}
	}
}

package core.site.transition {
	import core.site.interfaces.IPage;

	/**
	 * @author anthonysapp
	 */
	public class NormalTransitionActiveHandler extends AbstractTransitionActiveHandler {
		public function NormalTransitionActiveHandler() {
			super();
		}

		override public function isPageActiveForInTransition(page : IPage) : Boolean {
			var tArr : Array = facade.getTransitionArray();
			var ltArr : Array = facade.getLastTransitionArray();
			var pLevel : int = page.getLevel();
			if (page.getPageID() == 'site')pLevel = 0;
			if (tArr == null || ltArr == null)return true;
			//trace (page + 'in transition')
			//trace (page + ' pArr: ' + tArr + ' lpArr: ' + ltArr)
			//trace (page + ' plevel: ' + pLevel + ' tarr[pLevel]' + tArr[pLevel] + ' ltArr[pLevel]: ' + ltArr[pLevel])
			var result : Boolean = tArr[pLevel] == page.getPageID() && tArr[pLevel] != ltArr[pLevel];
			//trace ('the page: ' + page + ' active for in transition? ' + result )
			return result;
		}

		override public function isPageActiveForOutTransition(page : IPage) : Boolean {
			var tArr : Array = facade.getTransitionArray();
			var ltArr : Array = facade.getLastTransitionArray();
			
			var pLevel : int = page.getLevel();
			if (page.getPageID() == 'site')pLevel = 0;
			if (tArr == null || ltArr == null)return false;
			//trace (page.getPageID() + ' plevel: ' + pLevel + ' tarr[pLevel]' + tArr[pLevel])
			var result : Boolean = tArr[pLevel] != page.getPageID();
			//trace ('the page: ' + page + ' active for out transition? ' + result )
			return result;
		}
	}
}

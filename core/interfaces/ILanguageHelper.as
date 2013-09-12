package core.interfaces {

	/**
	 * @author anthonysapp
	 */
	public interface ILanguageHelper {
		function createTerms():void;
		function printAllTerms():void;
		function getText(textElementID:String):String;
	}
}

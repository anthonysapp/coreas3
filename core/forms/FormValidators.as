package core.forms {

	/**
	 * @author ted
	 */
	public class FormValidators {
		
		
		public static function validateString( textToValidate : String, validateType : String ) : Boolean {
			var _bool : Boolean;
			switch(validateType){
				case 'email':
					_bool = validateEmail(textToValidate);
				break;
				case 'postalcode':
				case 'postalCode':
				case 'postal_code':
					_bool = validatePostalCode(textToValidate);
				break;
				case 'birthday':
				case 'birthdate':
					_bool = validateBirthday(textToValidate);
				break;
				case 'phone_number':
				case 'phoneNumber':
				case 'phonenumber':
					_bool = validatePhoneNumber(textToValidate);
				break;
			}
			return _bool;
		}
		
		private static function validateEmail ( userEmail : String ) : Boolean{
			var validEmailRegExp:RegExp = /([a-z0-9._-]+)@([a-z0-9.-]+)\.([a-z]{2,4})/;
			return validEmailRegExp.exec(userEmail);
		}
		
		private static function validatePostalCode( postalCode : String ) : Boolean {
			var _upper : String = postalCode.toUpperCase();
			var postalCodeRegExp : RegExp = /^[ABCEGHJKLMNPRSTVXY]{1}\d{1}[A-Z]{1}( |-|)\d{1}[A-Z]{1}\d{1}$/;
			return postalCodeRegExp.exec(_upper);
		}
		
		private static function validatePhoneNumber ( phoneNumber : String ) : Boolean {
			var phoneNumberRegExp : RegExp = /\d{3}(-| |)\d{3}(-| |)\d{4}/;
			return phoneNumberRegExp.exec(phoneNumber);
		}
		
		private static function validateBirthday ( bDay : String ) : Boolean {
			var _count : int = 0;
			if ( bDay != '' ){
				var bDayArr : Array = bDay.split('-');
				var _year : Number = Number(bDayArr[0]);
				var _month : Number = Number(bDayArr[1]);
				var _day : Number = Number(bDayArr[2]);
				var _date : Date = new Date();
				var _currentYear : Number = _date.getFullYear();
				var _yearRange : Number = _currentYear - 100;
				
				if ( !isNaN(_year) && !isNaN(_month) && !isNaN(_day)){
					if ( _year > _yearRange && _year <= _currentYear ){
						_count += 1;
					}
					
					if ( _month >= 1 && _month <= 12 ){
						_count += 1;
					}
					
					if ( _day >= 1 && _day <= 31 ){
						_count += 1;
					}
					
					
				} else {
					
					return false;
				}
			}
			if ( _count == 3 ){
				return true;
			} else {
				return false;
			}
		}
	}
}

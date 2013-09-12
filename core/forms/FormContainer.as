package core.forms {
	import core.ObjectTracer;
	import core.utils.RequestUtil;
	import core.events.RequestEvent;

	import flash.display.InteractiveObject;

	import gs.TweenMax;

	import core.display.StateClip;

	import flash.events.FocusEvent;
	import flash.text.TextFormat;
	import flash.events.Event;

	import com.adobe.serialization.json.JSON;

	import flash.display.DisplayObject;
	import flash.net.URLVariables;	
	import flash.utils.Dictionary;	

	import fl.controls.*;
	import fl.core.UIComponent;
	import fl.events.ComponentEvent;

	import flash.display.MovieClip;

	/**
	 * @author ted
	 */
	public class FormContainer extends StateClip implements IFormContainer {
		public var tabLevel : int = 1000;
		public var offline : Boolean = false;
		//holds all UIComponents in form
		protected var _dict : Dictionary = new Dictionary(true) ;
		protected var _hidden : Dictionary = new Dictionary(true);
		//tabbing
		protected var _tabArray : Array = new Array();
		protected var sortOrder : Array = ['y','x'];

		private var _varsToSend : URLVariables;
		private var _prevToggledLabels : Array;
		private var _toggledLabels : Array;
		private var _modal : MovieClip;
		private var eDisplay : ErrorDisplay;
		private var _sending : Boolean = false;
		private var _formId : String = 'form';

		protected var _defaults : Dictionary = new Dictionary(true);
		protected var _errors : Dictionary = new Dictionary(true);
		protected var _notRequired : Dictionary = new Dictionary(true);
		protected var _groupDelimiters : Dictionary = new Dictionary(true);
		protected var _specialValidator : Dictionary = new Dictionary(true);
		protected var _refErrors : Array;
		protected var _startColor : uint = 0xFFFFFF;
		protected var _errorColor : uint = 0xA90101;
		protected var _useModal : Boolean = true;
		protected var _gateway : String = '';
		protected var _defaultErrorMessage : String = 'PLEASE DOUBLE CHECK THE FIELDS IN RED';
		protected var _thankYouMessage : String = '';

		//protected var _focusManager : FocusManager;

		protected var _enabled : Boolean = false;

		public function FormContainer() {
		}

		public override function setup() : void {
			super.setup();
			_enabled = true;
			var child : DisplayObject;
			for ( var i : uint = 0;i < this.numChildren;i++ ) {
				child = this.getChildAt(i);
				if ( child is UIComponent) {
					_dict[child.name] = child;
					if ( child is TextInput) {
						var ti : TextInput = child as TextInput;
						if (ti.text != '') {
							addDefault(ti, ti.text);
						}
					}
				} else if ( child is ErrorDisplay) {
					eDisplay = child as ErrorDisplay;
				} else if ( child is Modal ) {
					_modal = child as Modal;
				}
			}
			if ( eDisplay != null )eDisplay.hideError();
			if ( _modal != null ) {
				_modal.alpha = 0;
				_modal.visible = false;
			} else {
				createModal();
			}
			
			_toggledLabels = new Array();
			
			makeTabArray();
			addListeners();
			setEnabled();
		}

		private function makeTabArray() : void {
			_tabArray = new Array();
			for each (var displayObj:DisplayObject in _dict) {
				_tabArray.push(displayObj);
			}
		}

		protected function setEnabled() : void {
			/*if (_focusManager != null) {
			_focusManager.deactivate();
			_focusManager = null;
			}
			if (_enabled) {
			_focusManager = new FocusManager(this);
			_focusManager.activate();
			_focusManager.setFocus(this)
			}*/
			setComponentEnabled();
			setKeyboardListeners();
			setTabEnabled();
			
			if (_tabArray[0] is TextInput) {
				var ti : TextInput = _tabArray[0];
				ti.setFocus();
				ti.setSelection(0, ti.text.length - 1);
			}
		}

		public function addToTabArray(element : DisplayObject) : void {
			_tabArray.push(element);
		}

		protected function setComponentEnabled() : void {
			for each (var uic:UIComponent in _dict) {
				if (_enabled)uic.enabled = true; else disableFieldByName(uic.name, _defaults[uic]);
			}
		}

		protected function setTabEnabled() : void {
			if (!_enabled) {
				//removeTabs(); 
				return;
			}
			setTabOrder();
		}

		private function removeTabs() : void {
			if (_tabArray.length < 1)return;					
			var obj : InteractiveObject;
			var uic : UIComponent;
			for (var i : int = 0;i < _tabArray.length;i++) {
				obj = _tabArray[i];
				if (obj is UIComponent) {
					uic = (obj as UIComponent);
					uic.focusEnabled = false;
					uic.enabled = false;
				}
				obj.tabEnabled = false;
			}
		}

		protected function setTabOrder() : void {
			_tabArray.sortOn(sortOrder, Array.NUMERIC);
			var obj : InteractiveObject;
			var uic : UIComponent;									
			for (var i : int = 0;i < _tabArray.length;i++) {
				obj = _tabArray[i];
				if (obj is UIComponent) {
					uic = (obj as UIComponent);
					uic.enabled = true;
					uic.focusEnabled = true;
				}
				obj.tabEnabled = true;
				obj.tabIndex = i + tabLevel;
			}
		}

		protected function setKeyboardListeners() : void {
			for each (var uic:UIComponent in _dict) {
				if (!(uic is TextInput))continue;
				uic.removeEventListener(ComponentEvent.ENTER, sendForm);
				if (_enabled)uic.addEventListener(ComponentEvent.ENTER, sendForm);
			}
		}

		protected function addListeners() : void {
			addEventListener(FormEvent.ERROR, onFormError);			addEventListener(FormEvent.FAILED, onFormFail);			addEventListener(FormEvent.SENDING, onFormSend);			addEventListener(FormEvent.SUCCESS, onFormSuccess);
		}

		protected function removeListeners() : void {
			removeEventListener(FormEvent.ERROR, onFormError);
			removeEventListener(FormEvent.FAILED, onFormFail);
			removeEventListener(FormEvent.SENDING, onFormSend);
			removeEventListener(FormEvent.SUCCESS, onFormSuccess);
		}

		protected function onFormSuccess(event : FormEvent = null) : void {
			//trace ('success: ');
			//ObjectTracer.traceObj(event.data);
		}

		protected function onFormSend(event : FormEvent = null) : void {
			//trace ('send:');
		}

		protected function onFormFail(event : FormEvent = null) : void {
			//trace ('fail: ' + event.data);
		}

		protected function onFormError(event : FormEvent = null) : void {
			//trace ('error: ' + event.data);
		}

		public function addGroup(groupName : String, groupMembers : Array, delimiters : String = ',' ) : void {
			var _arr : Array = [];
			if ( _dict[groupName] == null ) {
				for each ( var item : String in groupMembers ) {
					_arr.push(_dict[item]);
					delete _dict[item];
				}
				_dict[groupName] = _arr;
			} 
			_groupDelimiters[groupName] = delimiters;
		}

		public function addHidden( _var : String, _value : * ) : void {
			_hidden[_var] = _value;
		}

		public function addDefault( field : *, defaultValue : String ) : void {
			_defaults[field] = defaultValue;
			
			field.text = defaultValue;
			field.addEventListener(FocusEvent.FOCUS_IN, textFieldGainedFocus);
			field.addEventListener(FocusEvent.FOCUS_OUT, textFieldLostFocus);
		}

		public function addSpecialValidator( special : *, type : String ) : void {
			if ( special is String ) {
				_specialValidator[special] = type;
			} else {
				_specialValidator[special.name] = type;
			}
		}

		public function disableFieldByName( fieldName : String, presetText : String = '' ) : void {
			_dict[fieldName].textField.text = presetText;
			_dict[fieldName].enabled = _dict[fieldName].tabEnabled = false;
			
			var dtf : TextFormat = _dict[fieldName].getStyle('textFormat');
			_dict[fieldName].setStyle('disabledTextFormat', dtf);
			_dict[fieldName].setStyle("embedFonts", true);
		}

		public function getValues(_value : *) : String { 
			if ( _value is ComboBox ) {
				if ( _value.selectedIndex >= 0)return _value.value;
			} else if ( (_value is TextInput) || (_value is TextArea )) {
				if ( _value.text != '')return checkDefault(_value.text, _value);	
			} else if ( _value is RadioButton ) {
				var _g : RadioButtonGroup = RadioButtonGroup.getGroup(_value.groupName);
				return  _g.selection.value.toString();
			} else if ( _value is CheckBox ) {
				return _value.selected.toString();
				//if (_value.selected) {
					//					if ( _value.label == '') {
					//						return 'true';
					//					} else {
					//						return _value.label;  
					//					}
				//}
			} else if ( _value is NumericStepper) {
				return String(_value.value);
			} else {
				return _value;	
			}
			return _notRequired[_value] != null ? 'notRequired' : 'null';
		}

		protected function checkDefault(_value : String, _container : UIComponent) : String {
			if ( _defaults[_container] != null) {
				if ( _defaults[_container] != _value ) {
					return _value;
				} else {
					return _notRequired[_container] != null ? 'notRequired' : 'null';
				}
			} else {
				return _value;
			}
		}

		public function getArrayValues( _arr : Array, index : String ) : String {
			var _collector : String = '';
			var clean_text : String = '';
			var _v : String;
			var groupCount : int = 0;
			
			for each ( var _i : * in _arr ) {
				if ( _i is RadioButton ) {
					groupCount++;
					if ( groupCount == _arr.length )return getValues(_arr[0]);
				} else {
					_v = getValues(_i);
					if ( _v != 'null') _collector += _v + _groupDelimiters[index];
				}
			}
			clean_text = _collector.substring(0, (_collector.length - 1));
			return clean_text;
		}

		public function setRequired(element : *) : void {
			if (_notRequired[element] == null)return;
			delete _notRequired[element];
		}

		public function removeRequired(element : *) : void {
			_notRequired[element] = true;
		}

		public function sendForm(e : Event = null) : void {
			var i : *;
			if ( !_sending ) {
				_sending = true;
				_varsToSend = new URLVariables();
				
				for (i in _hidden) {
					_varsToSend[i] = _hidden[i];
				}
				_refErrors = new Array();
				for (i in _dict) {
					if ( _dict[i] is Array ) {
						var _a : String = getArrayValues(_dict[i], i);
						if ( (_a != '') && (_notRequired[i] == undefined) ) {
							if ( _specialValidator[i] == null) {
								_varsToSend[i] = _a;
							} else {
								if (FormValidators.validateString(_a, _specialValidator[i])) {
									_varsToSend[i] = _a;
								} else {
									_refErrors.push(i);
								}
							}
							//_varsToSend[i] = _a;
						} else {
							_refErrors.push(i); 
						}
					} else {
						var _v : String = getValues(_dict[i]);
						//trace(i + ' value is: ' + _v);
						if ( (_v != 'null') && (_notRequired[i] == null) ) {
							if ( _specialValidator[i] == null) {
								_varsToSend[i] = _v;
							} else {
								if (FormValidators.validateString(_v, _specialValidator[i])) {
									_varsToSend[i] = _v;
								} else {
									if (_v != 'notRequired') {
										_refErrors.push(_dict[i]);
									}
								}
							}
						} else {
							_refErrors.push(_dict[i]);
						}
					}
				}
				//ObjectTracer.traceObj(_varsToSend);
				validateErrors();
				if ( _toggledLabels.length > 0) {
					dispatchEvent(new FormEvent(FormEvent.ERROR));
					displayErrors();
					_sending = false;
				} else {
					if ( eDisplay != null )eDisplay.hideError();
				
					if ( stage != null)stage.focus = stage;
					
					dispatchEvent(new FormEvent(FormEvent.SENDING, _varsToSend));
					if ( _modal != null ) {
						_modal.visible = true;
						if (_useModal)TweenMax.to(_modal, .3, {alpha:.5});
						else _modal.alpha = 0;
					}
					if (offline) {
						dispatchEvent(new FormEvent(FormEvent.SUCCESS, _varsToSend));
						return;
					}
					RequestUtil.addEventListener(RequestEvent.COMPLETE, checkResponse);
					RequestUtil.load(_gateway, _varsToSend, _formId);
				}
			}
		}

		private function checkResponse( e : RequestEvent ) : void {
			var _json : Object = JSON.decode(e.data);
			if ( !_json.success ) {
				// ERRORS GO HERE!
				TweenMax.to(_modal, .25, {alpha:0, delay:.5, onComplete: function() : void {
					_modal.visible = false;
					var _responseCode : String;
					if (_json.errors.length > 0) {
						_responseCode = _json.errors[0].code;
						if ( eDisplay != null ) {
							if ( _errors[_responseCode] != null)eDisplay.errorMessage = _errors[_responseCode];
						else eDisplay.errorMessage = _defaultErrorMessage;
						}
					}
					if (_json.exceptions.length > 0) {
						_responseCode = _json.exceptions[0].code;
						if ( eDisplay != null ) {
							if ( _errors[_responseCode] != null)eDisplay.errorMessage = _errors[_responseCode];
							else eDisplay.errorMessage = _defaultErrorMessage;
						}
					}
				}});
				if (e.id == _formId)dispatchEvent(new FormEvent(FormEvent.ERROR, _json));
				_sending = false;
			} else {
				TweenMax.to(_modal, .25, {alpha:0, onComplete: function() : void {
					_modal.visible = false;	
				}});
				if (_formId == String(e.id)) {
					if ( eDisplay != null ) {
						eDisplay.errorMessage = _thankYouMessage;
					}
					dispatchEvent(new FormEvent(FormEvent.SUCCESS, _json));
				}
				_sending = false;
			}
		}

		public function displayErrors() : void {
			toggleErrors((_prevToggledLabels.length > _toggledLabels.length) ? _prevToggledLabels : _toggledLabels);
			if ( eDisplay != null )eDisplay.errorMessage = _defaultErrorMessage;
			else trace('FormContainer :: your error display has not been set or found');
		}

		public function validateErrors() : void {
			var _name : String;
			if ( _toggledLabels != null)_prevToggledLabels = _toggledLabels;
			_toggledLabels = new Array();
			for ( var p : int = 0;p < _refErrors.length;p++) {
				if (_refErrors[p] is DisplayObject) {
					_name = _refErrors[p].name + '_label';
					_toggledLabels.push(_name);
				} else if ( _refErrors[p] is String ) {
					_name = _refErrors[p] + '_label';
					_toggledLabels.push(_name); 
				} 
			}
		}

		private function toggleErrors(_searchThrough : Array) : void {
			if ( _prevToggledLabels.length > 0) {
				//SHOW FIELDS WITH ERRORS
				for ( var i in _searchThrough ) {
					if (_toggledLabels.indexOf(_searchThrough[i]) == -1 )TweenMax.to(this[_searchThrough[i]], 1, {tint:_startColor, time:1});
					else TweenMax.to(this[_searchThrough[i]], .3, {tint:_errorColor});
				}
			} else {
				//FIRST TIME THROUGH
				for (var r in _toggledLabels) {
					TweenMax.to(this[_toggledLabels[r]], .3, {tint:_errorColor});
				}
			}
		}

		public function emptyFields() : void {
			for ( var a in _dict ) {
				if ( _dict[a] is Array ) {
					for ( var i in _dict[a] ) {
						if ( _dict[a][i] is TextInput || _dict[a][i] is TextArea ) {
							_dict[a][i].text = '';
						} else if ( _dict[a] is ComboBox ) {
							_dict[a].selectedIndex = -1;
						}
					}
				} else if ( _dict[a] is TextInput || _dict[a] is TextArea ) {
					_dict[a].text = '';
				} else if ( _dict[a] is ComboBox ) {
					_dict[a].selectedIndex = -1;
				}
			}
		}

		public function clearErrors() : void {
			for ( var i in _dict ) {
				TweenMax.to(this[i + '_label'], 0, {tint:_startColor});
			}
		}

		private function textFieldGainedFocus(e : FocusEvent) : void {
			if ( e.target.text == _defaults[e.target.parent]) {
				e.target.text = '';
			}
		}

		private function textFieldLostFocus(e : FocusEvent) : void {
			if ( e.target.text == '' || e.target.text == ' ') {
				e.target.text = _defaults[e.target.parent];
			}
		}

		private function createModal() : void {
			_modal = new MovieClip();
			_modal.graphics.beginFill(0xFFFFFF);
			_modal.graphics.drawRect(0, 0, this.width, this.height);
			_modal.graphics.endFill();
			this.addChild(_modal);
			_modal.alpha = 0;
			_modal.visible = false;
			_useModal = false;
		}

		public function get gateway() : String {
			return _gateway;
		}

		public function set gateway(_v : String) : void {
			_gateway = _v;
		}

		public function get defaultErrorMessage() : String {
			return _defaultErrorMessage;
		}

		public function set defaultErrorMessage( _v : String ) : void {
			_defaultErrorMessage = _v;
		}

		public function get useModal() : Boolean {
			return _useModal;
		}

		public function set useModal( _v : Boolean ) : void {
			_useModal = _v;
		}

		public function get formId() : String {
			return formId;
		}

		public function set formId( _v : String ) : void {
			_formId = _v;
		}

		public function get startColor() : uint {
			return _startColor;
		}

		public function set startColor(value : uint) : void {
			_startColor = value;
			clearErrors();
		}

		override public function get enabled() : Boolean {
			return _enabled;
		}

		override public function set enabled(value : Boolean) : void {
			if(_enabled == value)return;
			super.enabled = value;
			_enabled = value;
			setEnabled();
		}
	}
}

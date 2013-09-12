package core.utils {

	/**
	 * @author anthonysapp
	 */
	public class DateUtil {
		public static const MONTH_LABELS : Array = ["January",
                  "February",
                  "March",
                  "April",
                  "May",
                  "June",
                  "July",
                  "August",
                  "September",
                  "October",
                  "November",
                  "December"];
		public static const SHORT_MONTH_INDICES : Object = [{"Jan":0},
             		{"Feb":1},
             		{"Mar":2},
             		{"Apr":3},
             		{"May":4},
             		{"Jun":5},
             		{"Jul":6},
             		{"Aug":7},
             		{"Sep":8},
             		{"Oct":9},
             		{"Nov":10},
             		{"Dec":11}];

		public static function getFullMonthName(d : Date) : String {
			return MONTH_LABELS[d.getMonth()];
		}

		public static function getClockTime(hrs : uint, mins : uint) : String {
			var modifier : String = "PM";
			var minLabel : String = doubleDigitFormat(mins);

			if(hrs > 12) {
				hrs = hrs - 12;
			} else if(hrs == 0) {
				modifier = "AM";
				hrs = 12;
			} else if(hrs < 12) {
				modifier = "AM";
			}

			return (hrs + ":" + minLabel + " " + modifier);
		}

		public static function doubleDigitFormat(num : uint) : String {
			if(num < 10) {
				return ("0" + num);
			}
			return num.toString();
		}
		public static function parseDateString(input:String):Date{
			//2011-07-15 16:54:56
			var arr:Array = input.split(' ');
			var dateArr:Array = arr[0].split ('-');
			var timeArr:Array = arr[1].split (':');
			
			var d:Date = new Date(dateArr[0],int (dateArr[1])-1,dateArr[2],timeArr[0], timeArr[1],timeArr[2]);
			return d;
		}
		public static function parseRFC822(str : String, reorder : Boolean = false) : Date {
			//Wed, 02 Oct 2002 15:00:00 +0200
			//Mon Jul 11 15:40:04 +0000 2011
			//|Mon|Jul|11|15:40:04|+0000|2011
			//Thu, Jul 14 +0000 2011 13:30:13
			if (reorder) {
				try {
					parseRFC822(str);
				}catch (e : *) {
					var darr : Array = str.split(' ');
					str = darr[0] + ', ' + darr[2] + ' ' + darr[1] + ' ' + darr[5] + ' ' + darr[3] + ' ' + darr[4];
					str = str.replace(',,', ',');
					return parseRFC822(str);
				}
			}
			var finalDate : Date;
			try {
				var dateParts : Array = str.split(" ");
				var day : String = null;
				
				if (dateParts[0].search(/\d/) == -1) {
					day = dateParts.shift().replace(/\W/, "");
				}
				
				var date : Number = Number(dateParts.shift());
				var month : Number = Number(DateUtil.getShortMonthIndex(dateParts.shift()));
				var year : Number = Number(dateParts.shift());
				var timeParts : Array = dateParts.shift().split(":");
				var hour : Number = int(timeParts.shift());
				var minute : Number = int(timeParts.shift());
				var second : Number = (timeParts.length > 0) ? int(timeParts.shift()) : 0;
	
				var milliseconds : Number = Date.UTC(year, month, date, hour, minute, second, 0);
	
				var timezone : String = dateParts.shift();
				var offset : Number = 0;

				if (timezone.search(/\d/) == -1) {
					switch(timezone) {
						case "UT":
							offset = 0;
							break;
						case "UTC":
							offset = 0;
							break;
						case "GMT":
							offset = 0;
							break;
						case "EST":
							offset = (-5 * 3600000);
							break;
						case "EDT":
							offset = (-4 * 3600000);
							break;
						case "CST":
							offset = (-6 * 3600000);
							break;
						case "CDT":
							offset = (-5 * 3600000);
							break;
						case "MST":
							offset = (-7 * 3600000);
							break;
						case "MDT":
							offset = (-6 * 3600000);
							break;
						case "PST":
							offset = (-8 * 3600000);
							break;
						case "PDT":
							offset = (-7 * 3600000);
							break;
						case "Z":
							offset = 0;
							break;
						case "A":
							offset = (-1 * 3600000);
							break;
						case "M":
							offset = (-12 * 3600000);
							break;
						case "N":
							offset = (1 * 3600000);
							break;
						case "Y":
							offset = (12 * 3600000);
							break;
						default:
							offset = 0;
					}
				} else {
					var multiplier : Number = 1;
					var oHours : Number = 0;
					var oMinutes : Number = 0;
					if (timezone.length != 4) {
						if (timezone.charAt(0) == "-") {
							multiplier = -1;
						}
						timezone = timezone.substr(1, 4);
					}
					oHours = Number(timezone.substr(0, 2));
					oMinutes = Number(timezone.substr(2, 2));
					offset = (((oHours * 3600000) + (oMinutes * 60000)) * multiplier);
				}

				finalDate = new Date(milliseconds - offset);

				if (finalDate.toString() == "Invalid Date") {
					throw new Error("This date does not conform to RFC822.");
				}
			}
			catch (e : Error) {
				var eStr : String = "Unable to parse the string [" + str + "] into a date. ";
				eStr += "The internal error was: " + e.toString();
				throw new Error(eStr);
			}
			return finalDate;
		}

		private static function getShortMonthIndex(name : String) : int {
			return SHORT_MONTH_INDICES[name];
		}
	}
}

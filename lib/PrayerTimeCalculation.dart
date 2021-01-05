import 'dart:collection';
import 'dart:math' as math;
import 'dart:core';

void main(){

  var currentTime = DateTime.now();
  PrayerTime prayers = new PrayerTime();
  prayers.setTimeFormat(prayers.getTime12());
  prayers.setCalcMethod(prayers.getKarachi());
  prayers.setAsrJuristic(prayers.getKarachi());
  prayers.setAdjustHighLats(prayers.getAdjustHighLats());

  //Providing Location of Mymensingh
  //Lat 24.78 , lon 90.42 GMT +6
  print('Your Location is : Kalibari Road, Ishwarganj, Mymensingh');
  print(currentTime);
  List<dynamic> timeList=prayers.getPrayerTimes(currentTime, 24.6923, 90.5944 , 6.0); //Provided time,lat,long,zone
  List<String> prayerTimeNames= prayers.getTimeNames();
  //Making string to actual Time ;
  for (int i=0 ; i<timeList.length ; i++){
    print('${prayerTimeNames[i]} ${timeList[i]}');
  }
}

class PrayerTime {
  int _calcMethod;
  int _asrJuristic;
  int _dhuhrMinutes;
  int _adjustHighLats;
  int _timeFormat;
  double _lat;
  double _lng;
  double _timeZone;
  double _jDate;
  int _jafri;
  int _karachi;
  int _iSNA;
  int _mWL;
  int _makkah;
  int _egypt;
  int _custom;
  int _tehran;
  int _shaffi;
  int _hanafi;

  int _none;
  int _midNight;
  int _oneSeventh;
  int _angleBased;

  int _time24;
  int _time12;
  int _time12Ns;
  int _floating;

  List<String> _timeNames;
  String _invalidTime;
  int _numIterations;
  Map<int, List<double>> _methodParams;

  List<int> _offsets;

  PrayerTime() {
    this.setCalcMethod(0);
    this.setAsrJuristic(0);
    this.setDhuhrMinutes(0);
    this.setAdjustHighLats(1);
    this.setTimeFormat(0);

    this.setJafari(0);
    this.setKarachi(1);
    this.setISNA(2);
    this.setMWL(3);
    this.setMakkah(4);
    this.setEgypt(5);
    this.setTehran(6);
    this.setCustom(7);

    this.setShafii(0);
    this.setHanafi(1);

    this.setNone(0);
    this.setMidNight(1);
    this.setOneSeventh(2);
    this.setAngleBased(3);

    this.setTime24(0);
    this.setTime12(1);
    this.setTime12NS(2);
    this.setFloating(3);

    _timeNames = new List<String>();
    _timeNames.add("ফজর");
    _timeNames.add("সূর্যোদয়");
    _timeNames.add("যোহর");
    _timeNames.add("আসর");
    _timeNames.add("সূর্যাস্ত");
    _timeNames.add("মাগরিব");
    _timeNames.add("এশা");
    _invalidTime = "-----";

    this.setNumIterations(1);

    _offsets = new List<int>(7);
    _offsets[0] = 0;
    _offsets[1] = 0;
    _offsets[2] = 0;
    _offsets[3] = 0;
    _offsets[4] = 0;
    _offsets[5] = 0;
    _offsets[6] = 0;

    _methodParams = new HashMap<int, List<double>>();

    List<double> _jValues = [16, 0, 4, 0, 14];
    _methodParams[this.getJafari()] = _jValues;

    List<double> _kValues = [18, 1, 0, 0, 18];
    _methodParams[this.getKarachi()] = _kValues;

    List<double> _iValues = [15, 1, 0, 0, 15];
    _methodParams[this.getISNA()] = _iValues;

    List<double> _mwValues = [18, 1, 0, 0, 17];
    _methodParams[this.getMWL()] = _mwValues;

    List<double> _mkValues = [18.5, 1, 0, 1, 90];
    _methodParams[this.getMakkah()] = _mkValues;

    List<double> _eValues = [20, 1, 0, 0, 18];
    _methodParams[this.getEgypt()] = _eValues;

    List<double> _tValues = [17.7, 0, 4.5, 0, 14];
    _methodParams[this.getTehran()] = _tValues;

    List<double> _cValues = [18, 1, 0, 0, 17];
    _methodParams[this.getCustom()] = _cValues;
  }

  double _fixAngle(double a) {
    a = a - (360 * ((a / 360.0).floor()));
    a = a < 0 ? (a + 360) : a;

    return a;
  }

  double _fixHour(double a) {
    a = a - 24.0 * (a / 24.0).floor();
    a = a < 0 ? (a + 24) : a;
    return a;
  }

  double _radiansToDegrees(double alpha) {
    return ((alpha * 180.0) / math.pi);
  }

  double _degreesToRadians(double alpha) {
    return ((alpha * math.pi) / 180.0);
  }

  double _dsin(double d) {
    return (math.sin(_degreesToRadians(d)));
  }

  double _dcos(double d) {
    return (math.cos(_degreesToRadians(d)));
  }

  double _dtan(double d) {
    return (math.tan(_degreesToRadians(d)));
  }

  double _darcsin(double x) {
    double val = math.asin(x);
    return _radiansToDegrees(val);
  }

  double darccos(double x) {
    double val = math.acos(x);
    return _radiansToDegrees(val);
  }


  double _darctan2(double y, double x) {
    double val = math.atan2(y, x);
    return _radiansToDegrees(val);
  }

  double darccot(double x) {
    double val = math.atan2(1.0, x);
    return _radiansToDegrees(val);
  }

  julianDate(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    double A = (year / 100.0).floorToDouble();

    double B = 2 - A + (A / 4.0).floor();

    double JD = (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        B -
        1524.5;

    return JD;
  }

  List<double> sunPosition(double jd) {
    double D = jd - 2451545;
    double g = _fixAngle(357.529 + 0.98560028 * D);
    double q = _fixAngle(280.459 + 0.98564736 * D);
    double L = _fixAngle(q + (1.915 * _dsin(g)) + (0.020 * _dsin(2 * g)));

    double e = 23.439 - (0.00000036 * D);
    double d = _darcsin(_dsin(e) * _dsin(L));
    double RA = (_darctan2((_dcos(e) * _dsin(L)), (_dcos(L)))) / 15.0;
    RA = _fixHour(RA);
    double EqT = q / 15.0 - RA;
    List<double> sPosition = new List(2);
    sPosition[0] = d;
    sPosition[1] = EqT;

    return sPosition;
  }

  double equationOfTime(double jd) {
    double eq = sunPosition(jd)[1];
    return eq;
  }

  double sunDeclination(double jd) {
    double d = sunPosition(jd)[0];
    return d;
  }

  double computeMidDay(double t) {
    double T = equationOfTime(this.getJDate() + t);
    double Z = _fixHour(12 - T);
    return Z;
  }

  double computeTime(double G, double t) {
    double D = sunDeclination(this.getJDate() + t);
    double Z = computeMidDay(t);
    double Beg = -_dsin(G) - _dsin(D) * _dsin(this.getLat());
    double Mid = _dcos(D) * _dcos(this.getLat());
    double V = darccos(Beg / Mid) / 15.0;

    return Z + (G > 90 ? -V : V);
  }

  double computeAsr(double step, double t) {
    double D = sunDeclination(this.getJDate() + t);
    double G = -darccot(step + _dtan((this.getLat() - D).abs()));
    return computeTime(G, t);
  }

  double timeDiff(double time1, double time2) {
    return _fixHour(time2 - time1);
  }

  List<String> getDatePrayerTimes(int year, int month, int day, double latitude,
      double longitude, double tZone) {
    this.setLat(latitude);
    this.setLng(longitude);
    this.setTimeZone(tZone);
    this.setJDate(julianDate(year, month, day));
    double lonDiff = longitude / (15.0 * 24.0);
    this.setJDate(this.getJDate() - lonDiff);
    return computeDayTimes();
  }

  List<String> getPrayerTimes(
      DateTime date, double latitude, double longitude, double tZone) {
    int year = date.year;
    int month = date.month;
    int day = date.day;

    return getDatePrayerTimes(year, month, day, latitude, longitude, tZone);
  }

  void setCustomParams(List<double> params) {
    for (int i = 0; i < 5; i++) {
      if (params[i] == null) {
        params[i] = _methodParams[this._calcMethod][i];
        _methodParams[this.getCustom()] = params;
      } else {
        _methodParams[this.getCustom()][i] = params[i];
      }
    }
    this.setCalcMethod(this.getCustom());
  }

  void setFajrAngle(double angle) {
    List<double> params = [angle, -1, -1, -1, -1];
    setCustomParams(params);
  }

  void setMaghribAngle(double angle) {
    List<double> params = [-1, 0, angle, -1, -1];
    setCustomParams(params);
  }

  void setIshaAngle(double angle) {
    List<double> params = [-1, -1, -1, 0, angle];
    setCustomParams(params);
  }

  void setMaghribMinutes(double minutes) {
    List<double> params = [-1, 1, minutes, -1, -1];
    setCustomParams(params);
  }

  void setIshaMinutes(double minutes) {
    List<double> params = [-1, -1, -1, 1, minutes];
    setCustomParams(params);
  }

  String floatToTime24(double time) {
    String result;

    if (time == double.nan) {
      return _invalidTime;
    }

    time = _fixHour(time + 0.5 / 60.0); // add 0.5 minutes to round
    int hours = time.floor();
    double minutes = ((time - hours) * 60.0).floorToDouble();

    if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
      result = "0" + hours.toString() + ":0" + (minutes).round().toString();
    } else if ((hours >= 0 && hours <= 9)) {
      result = "0" + hours.toString() + ":" + (minutes).round().toString();
    } else if ((minutes >= 0 && minutes <= 9)) {
      result = hours.toString() + ":0" + (minutes).round().toString();
    } else {
      result = hours.toString() + ":" + (minutes).round().toString();
    }
    return result;
  }

  String floatToTime12(double time, bool noSuffix) {
    if (time == double.nan) {
      return _invalidTime;
    }

    time = _fixHour(time + 0.5 / 60); // add 0.5 minutes to round
    int hours = (time).floor();
    double minutes = ((time - hours) * 60).floorToDouble();
    String suffix, result;
    if (hours >= 12) {
      suffix = "PM";
    } else {
      suffix = "AM";
    }
    hours = ((((hours + 12) - 1) % (12)) + 1);
    if (noSuffix == false) {
      if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
        result = "0" +
            hours.toString() +
            ":0" +
            (minutes).round().toString() +
            " " +
            suffix;
      } else if ((hours >= 0 && hours <= 9)) {
        result = "0" +
            hours.toString() +
            ":" +
            (minutes).round().toString() +
            " " +
            suffix;
      } else if ((minutes >= 0 && minutes <= 9)) {
        result = hours.toString() +
            ":0" +
            (minutes).round().toString() +
            " " +
            suffix;
      } else {
        result = hours.toString() +
            ":" +
            (minutes).round().toString() +
            " " +
            suffix;
      }
    } else {
      if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
        result = "0" + hours.toString() + ":0" + (minutes).round().toString();
      } else if ((hours >= 0 && hours <= 9)) {
        result = "0" + hours.toString() + ":" + (minutes).round().toString();
      } else if ((minutes >= 0 && minutes <= 9)) {
        result = hours.toString() + ":0" + (minutes).round().toString();
      } else {
        result = hours.toString() + ":" + (minutes).round().toString();
      }
    }
    return result;
  }

  String floatToTime12NS(double time) {
    return floatToTime12(time, true);
  }

  List<double> computeTimes(List<double> times) {
    List<double> t = dayPortion(times);

    double Fajr =
    this.computeTime(180 - _methodParams[this.getCalcMethod()][0], t[0]);

    double Sunrise = this.computeTime(180 - 0.833, t[1]);

    double Dhuhr = this.computeMidDay(t[2]);
    double Asr = this.computeAsr((1 + this.getAsrJuristic()).toDouble(), t[3]);
    double Sunset = this.computeTime(0.833, t[4]);

    double Maghrib =
    this.computeTime(_methodParams[this.getCalcMethod()][2], t[5]);
    double Isha =
    this.computeTime(_methodParams[this.getCalcMethod()][4], t[6]);

    List<double> CTimes = [Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha];

    return CTimes;
  }

  List<String> computeDayTimes() {
    List<double> times = [5, 6, 12, 13, 18, 18, 18]; // default times

    for (int i = 1; i <= this.getNumIterations(); i++) {
      times = computeTimes(times);
    }

    times = adjustTimes(times);
    times = tuneTimes(times);

    return adjustTimesFormat(times);
  }

  List<double> adjustTimes(List<double> times) {
    for (int i = 0; i < times.length; i++) {
      times[i] += this.getTimeZone() - this.getLng() / 15;
    }

    times[2] += this.getDhuhrMinutes() / 60; // Dhuhr

    if (_methodParams[this.getCalcMethod()][1] == 1) {
      times[5] = times[4] + _methodParams[this.getCalcMethod()][2] / 60;
    }
    if (_methodParams[this.getCalcMethod()][3] == 1) {
      times[6] = times[5] + _methodParams[this.getCalcMethod()][4] / 60;
    }

    if (this.getAdjustHighLats() != this.getNone()) {
      times = adjustHighLatTimes(times);
    }

    return times;
  }

  List<String> adjustTimesFormat(List<double> times) {
    List<String> result = new List<String>();
    if (this.getTimeFormat() == this.getFloating()) {
      for (double time in times) {
        result.add(time.toString());
      }
      return result;
    }

    for (int i = 0; i < 7; i++) {
      if (this.getTimeFormat() == this.getTime12()) {
        result.add(floatToTime12(times[i], false));
      } else if (this.getTimeFormat() == this.getTime12NS()) {
        result.add(floatToTime12(times[i], true));
      } else {
        result.add(floatToTime24(times[i]));
      }
    }
    return result;
  }

  List<double> adjustHighLatTimes(List<double> times) {
    double nightTime = timeDiff(times[4], times[1]); // sunset to sunrise

    double FajrDiff =
        nightPortion(_methodParams[this.getCalcMethod()][0]) * nightTime;

    if (times[0] == double.nan || timeDiff(times[0], times[1]) > FajrDiff) {
      times[0] = times[1] - FajrDiff;
    }

    double IshaAngle = (_methodParams[this.getCalcMethod()][3] == 0)
        ? _methodParams[this.getCalcMethod()][4]
        : 18;
    double IshaDiff = this.nightPortion(IshaAngle) * nightTime;

    if (times[6] == double.nan ||
        this.timeDiff(times[4], times[6]) > IshaDiff) {
      times[6] = times[4] + IshaDiff;
    }

    double MaghribAngle = (_methodParams[this.getCalcMethod()][1] == 0)
        ? _methodParams[(this.getCalcMethod())][2]
        : 4;
    double MaghribDiff = nightPortion(MaghribAngle) * nightTime;

    if (times[5] == double.nan ||
        this.timeDiff(times[4], times[5]) > MaghribDiff) {
      times[5] = times[4] + MaghribDiff;
    }

    return times;
  }

  double nightPortion(double angle) {
    double calc = 0;

    if (_adjustHighLats == _angleBased)
      calc = (angle) / 60.0;
    else if (_adjustHighLats == _midNight)
      calc = 0.5;
    else if (_adjustHighLats == _oneSeventh) calc = 0.14286;

    return calc;
  }

  List<double> dayPortion(List<double> times) {
    for (int i = 0; i < 7; i++) {
      times[i] /= 24;
    }
    return times;
  }

  void tune(List<int> offsetTimes) {
    for (int i = 0; i < offsetTimes.length; i++) {
      this._offsets[i] = offsetTimes[i];
    }
  }

  List<double> tuneTimes(List<double> times) {
    for (int i = 0; i < times.length; i++) {
      times[i] = times[i] + this._offsets[i] / 60.0;
    }
    return times;
  }

  int getCalcMethod() {
    return _calcMethod;
  }

  void setCalcMethod(int calcMethod) {
    _calcMethod = calcMethod;
  }

  int getAsrJuristic() {
    return _asrJuristic;
  }

  void setAsrJuristic(int asrJuristic) {
    _asrJuristic = asrJuristic;
  }

  int getDhuhrMinutes() {
    return _dhuhrMinutes;
  }

  void setDhuhrMinutes(int dhuhrMinutes) {
    _dhuhrMinutes = dhuhrMinutes;
  }

  int getAdjustHighLats() {
    return _adjustHighLats;
  }

  void setAdjustHighLats(int adjustHighLats) {
    _adjustHighLats = adjustHighLats;
  }

  int getTimeFormat() {
    return _timeFormat;
  }

  setTimeFormat(int timeFormat) {
    _timeFormat = timeFormat;
  }

  double getLat() {
    return _lat;
  }

  void setLat(double lat) {
    _lat = lat;
  }

  double getLng() {
    return _lng;
  }

  void setLng(double lng) {
    _lng = lng;
  }

  double getTimeZone() {
    return _timeZone;
  }

  void setTimeZone(double timeZone) {
    _timeZone = timeZone;
  }

  double getJDate() {
    return _jDate;
  }

  void setJDate(double jDate) {
    _jDate = jDate;
  }

  int getJafari() {
    return _jafri;
  }

  void setJafari(int jafari) {
    _jafri = jafari;
  }

  int getKarachi() {
    return _karachi;
  }

  void setKarachi(int karachi) {
    _karachi = karachi;
  }

  int getISNA() {
    return _iSNA;
  }

  void setISNA(int iSNA) {
    _iSNA = iSNA;
  }

  int getMWL() {
    return _mWL;
  }

  void setMWL(int mWL) {
    _mWL = mWL;
  }

  int getMakkah() {
    return _makkah;
  }

  void setMakkah(int makkah) {
    _makkah = makkah;
  }

  int getEgypt() {
    return _egypt;
  }

  void setEgypt(int egypt) {
    _egypt = egypt;
  }

  int getCustom() {
    return _custom;
  }

  void setCustom(int custom) {
    _custom = custom;
  }

  int getTehran() {
    return _tehran;
  }

  void setTehran(int tehran) {
    _tehran = tehran;
  }

  int getShafii() {
    return _shaffi;
  }

  void setShafii(int shafii) {
    _shaffi = shafii;
  }

  int getHanafi() {
    return _hanafi;
  }

  void setHanafi(int hanafi) {
    _hanafi = hanafi;
  }

  int getNone() {
    return _none;
  }

  void setNone(int none) {
    _none = none;
  }

  int getMidNight() {
    return _midNight;
  }

  void setMidNight(int midNight) {
    _midNight = midNight;
  }

  int getOneSeventh() {
    return _oneSeventh;
  }

  void setOneSeventh(int oneSeventh) {
    _oneSeventh = oneSeventh;
  }

  int getAngleBased() {
    return _angleBased;
  }

  void setAngleBased(int angleBased) {
    _angleBased = angleBased;
  }

  int getTime24() {
    return _time24;
  }

  void setTime24(int time24) {
    _time24 = time24;
  }

  int getTime12() {
    return _time12;
  }

  void setTime12(int time12) {
    _time12 = time12;
  }

  int getTime12NS() {
    return _time12Ns;
  }

  void setTime12NS(int time12ns) {
    _time12Ns = time12ns;
  }

  int getFloating() {
    return _floating;
  }

  void setFloating(int floating) {
    _floating = floating;
  }

  int getNumIterations() {
    return _numIterations;
  }

  void setNumIterations(int numIterations) {
    _numIterations = numIterations;
  }

  List<String> getTimeNames() {
    return _timeNames;
  }
}

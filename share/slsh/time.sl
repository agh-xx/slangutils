_traceback = 1;
variable Months =
  ["January", "February", "March", "April", "May", "June", "July",
   "August", "September", "October", "November", "December"],
  Week_days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

define julian_day_number (hour, day, month, year)
{
 % http://en.wikipedia.org/wiki/Julian_day
 % until 1/1/4713 B.C

 if (year == 1582 && month == 10  && (day < 15 && day > 4))
   % Calendar change
   return -1;

variable jdn, newmonth, newyear, a = (14 - month) / 12;

  newyear = (year + 4801 - _ispos (year)) - a;
  newmonth = month +  (12 * a) - 3;

  if (year > 1582 || (year == 1582 && (month > 10 || (month ==10 && day > 4))))
    jdn = day + ((153 * newmonth + 2) / 5) + (newyear * 365) + (newyear / 4)
           - (newyear / 100) + (newyear / 400) - 32045;
  else
    jdn = day + (153 * newmonth + 2) / 5 + newyear * 365 + newyear / 4 - 32083;

  if (hour  < 12 && hour >= 0)
     jdn --;

  return jdn;
}

define week_day (day, month, year)
{
  variable jdn = julian_day_number (12, day, month, year);

  if (jdn == -1)
    return -1;

  variable a = (14 - month) / 12;

  year = year - a + _isneg (year);
  month = month + (12 * a ) - 2;

  if (jdn > 2299160)
    day = (day + year + (year / 4) - (year / 100) +  (year / 400)
           + (31 * month) / 12) mod 7;
  else
    day = (5 + day + year + year / 4 + (31 * month) / 12) mod 7;

  return day;
}

define julian_day_to_cal (jdn)
{
  variable a, year, z = jdn;

  if (jdn > 2299160)
    {
      variable
        w = typecast (((z - 1867216.25) / 36524.25), Int_Type),
        x = typecast (w / 4, Int_Type);
      a = z + 1 + w - x;
    }
  else
    a = z;

  variable
    b = a + 1524,
    c = typecast ((b - 122.1) / 365.25, Int_Type),
    d = typecast (365.25 * c, Int_Type),
    e = typecast ((b - d) / 30.6001, Int_Type),
    f = typecast (30.6001 * e, Int_Type),
    day = b - d - f,
    month = e - 1;

  if (month > 12)
    month = e - 13;

  if (month == 1 || month == 2)
    year = c - 4715;
  else
    year = c - 4716;

  variable weekday = week_day (day, month, year);
  if (-1 == weekday)
    return -1;

  return strcat (string (day), " ", Months[month - 1], ", ",
                 string (year), ", ", Week_days[weekday]);
}

define __is_leap (year)
{
  if ((0 == year mod 4 && 0 != year mod 100) || 0 == year mod 400)
    return 1;

  return 0;
}

define year_days (year)
{
  return 365 + __is_leap (year);
}

define week_iso (day, month, year)
{
  variable jdn = julian_day_number (12, day, month, year);
  if (-1 == jdn)
    return -1;

  variable
    d4 = (jdn + 31741 - ( jdn mod 7)) mod 146097 mod 36524 mod 1461,
    l = d4 / 1460,
    d1 = ((d4 - l) mod 365) + l,
    weeknumber = d1 / 7 + 1,
    weekday = week_day (day, month, year);

  if (-1 == weekday) return -1;

  if (month == 1 && weeknumber == 53)
    return strcat ( string (year - 1), "-W", string (weeknumber),
                    "-", Week_days[weekday]);
  else if (month == 12 && weeknumber == 1)
    return strcat ( string (year + 1), "-W", string (weeknumber),
                    "-", Week_days[weekday]);
  else
    return strcat (string (year), "-W", string (weeknumber),
                   "-", Week_days[weekday]);
}

define month_abbr (month)
{

  variable m;
  _for m (0,  length (Months) -1, 1)
    if (string_match (strup (Months[m]), strup (month), 1))
      return m + 1;

  return -1;
}

define month_days (month, year)
{
  variable days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  if (month == 2)
    return days[month - 1] + __is_leap (year);
  else
    return days[month - 1];
}

define dayoftheyear (day, month, year)
{
  if (month > 1)
    {
      variable newmonth = 2, days = 31;
      while (newmonth != month)
        {
          days += month_days (newmonth, year);
          newmonth ++;
        }
      return days + day;
    }
  else
   return day;
}

define time_now ()
{
  variable tm = localtime (_time ());
  return strftime ("%a %d %b %Y %r %Z", tm);
}

define easter_orthodox (year)
{
  variable easterday,
    g = year mod 19,
    i = (19 * g + 15) mod 30,
    j = (year + year / 4 + i) mod 7,
    l = i - j,
    eastermonth = 3 + (l +40) / 44;

  if (year < 1921)
    {
      ()= fputs ("This is a date in Julian Calendar (pre 1921)", stdout);
       easterday = l + 28 - 31 * (eastermonth / 4);
    }
  else
    {
      if (year >= 2100)
        easterday = l + 28 - 31 * (eastermonth / 4) + 14;
      else    
        easterday = l + 28 - 31 * (eastermonth / 4) + 13;
      
      if (easterday > 30 && eastermonth == 4)
        {
          eastermonth = "May";
          easterday -= 30;
        }
      else if (easterday > 30 && eastermonth == 3)
        {
          easterday -= 31;
          eastermonth = "April";
        }
      else
        eastermonth = "April";
    }    

  return strcat (string (easterday), " ", eastermonth);
}

define easter_catholic (year)
{
  if (year == 4089)
    return -1;
  variable eastermonth,
    a = year / 100,
    b = year mod 100,
    c = (3 * (a + 25)) / 4,
    d = (3 * (a + 25)) mod 4,
    e = (8 * (a + 11)) / 25,
    f = (5 * a + b) mod 19,
    g = (19 * f + c - e) mod 30,
    h = (f + 11 * g) / 319,
    j = (60 * (5 - d) + b) / 4,
    k = (60 * (5 - d) + b) mod 4,
    m = ( 2 * j - k - g + h) mod 7,
    n = ( g - h + m + 114) / 31,
    p = ( g - h + m + 114) mod 31,
    easterday = p + 1;

  eastermonth = n == 3 ? "March" : "April";

  return strcat (string (easterday), " ", eastermonth);
}

define normalize (v)
{
  v = v - floor(v);
  if (v < 0)
    v = v + 1;
  
  return v;
}

define round2 (x)
{
  return (round (100 * x) / 100.0);
}

define phase ()
{
  % Thanks goes to
  % http://home.att.net/~srschmitt/zenosamples/zs_lunarphasecalc.html
  % for the moonphase algorithm

  variable
    pi = 3.1415926535897932385,
    timeformat, hour, minu, sec, day, month, year;
  
  ifnot (_NARGS)
    {
      timeformat = strftime("%T:%d:%m:%Y", localtime(_time));
      ()= sscanf (timeformat, "%d:%d:%d:%d:%d:%d", &hour, &minu, &sec, &day, &month, &year);
    }
  else
    {
      timeformat = __pop_list (_NARGS);
      (hour, minu, sec, day, month, year) = __push_list (timeformat);
    }

  if ((year >= 2038) && (month >= 1) && (day >= 19) && (hour >= 3) && (min >= 14) && (sec >= 7))
    return -1;
    
  variable phase,
    jdn = julian_day_number (hour, day, month, year),
    ip = (jdn - 2451550.1) / 29.530588853,
    ag = normalize (ip) * 29.53;

  if (ag <  1.84566)
    phase = "NEW";
  else if (ag <  5.53699)
    phase = "Waxing crescent";
  else if (ag <  9.22831)
    phase = "First quarter";
  else if (ag < 12.91963)
    phase = "Waxing gibbous";
  else if (ag < 16.61096)
    phase = "FULL";
  else if (ag < 20.30228)
    phase = "Waning gibbous";
  else if (ag < 23.99361)
    phase = "Last quarter";
  else if (ag < 27.68493)
    phase = "Waning crescent";
  else                    
    phase = "NEW";

  ip = ip * 2 * pi;
   
  variable zodiac,
    dp = 2 * pi * normalize ((jdn - 2451562.2) / 27.55454988),
    di = 60.4 - 3.3 * cos (dp) - 0.6 * cos (2 * ip - dp) - 0.5 * cos (2 * ip),
    np = 2 * pi * normalize ((jdn - 2451565.2 ) / 27.212220817),
    la = 5.1 * sin (np),
    rp = normalize ((jdn - 2451555.8) / 27.321582241),
    lo = 360 * rp + 6.3 * sin (dp) + 1.3 * sin (2 * ip - dp) + 0.7 * sin (2 * ip);

  if (lo < 33.18)
    zodiac = "Pisces";
  else if (lo <  51.16)
    zodiac = "Aries";
  else if (lo <  93.44)
    zodiac = "Taurus";
  else if (lo < 119.48)
    zodiac = "Gemini";
  else if (lo < 135.30)
    zodiac = "Cancer";
  else if (lo < 173.34)
    zodiac = "Leo";
  else if (lo < 224.17)
    zodiac = "Virgo";
  else if (lo < 242.57)
    zodiac = "Libra";
  else if (lo < 271.26)
    zodiac = "Scorpio";
  else if (lo < 302.49)
    zodiac = "Sagittarius";
  else if (lo < 311.72)
    zodiac = "Capricorn";
  else if (lo < 348.58)
    zodiac = "Aquarius";
  else 
    zodiac = "Pisces";

  variable report = [
    sprintf ("Date: %s\n", julian_day_to_cal (jdn)),
    sprintf ("Phase: %13s\n", phase),
    sprintf ("Age: %16S days (%S)\n", round2 (ag), round2 (ag) / 29.530588853),
    sprintf ("Distance:  %10S earth radii\n", round2 (di)),
    sprintf ("Latitude: %11S°\n", round2 (la)),
    sprintf ("Longitude:%12S°\n", round2 (lo)),
    sprintf ("Constellation: %6s\n", zodiac)];

  foreach (report)
    {
      variable item = ();
      () = fputs (item, stdout);
    }
}


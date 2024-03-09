# DateTimeクラスの定義
Time::DATE_FORMATS[:time_datetime] = '%Y/%m/%d %H:%M:%S' # 2018/01/01 00:00:00
Time::DATE_FORMATS[:time_date] = '%Y/%m/%d' # 2018/01/01

# Dateクラスの定義
Date::DATE_FORMATS[:date] = "%-m/%-d"
Date::DATE_FORMATS[:yeardate] = "%Y/%-m/%-d" # 2018/1/1
Date::DATE_FORMATS[:yeardate_with_zero] = "%Y/%m/%d" # 2018/01/01
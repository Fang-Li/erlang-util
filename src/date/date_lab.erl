-module(date_lab).
-compile(export_all).

test(Duration,{{Y,Mm,D}, {H, M, S}}) ->

    NowSecs = calendar:datetime_to_gregorian_seconds({{Y,Mm,D}, {H, M, S}}),
    Total_Hours_From_Now =  Duration * 60 * 60,
    NewTimeSecs = NowSecs + Total_Hours_From_Now,
    calendar:gregorian_seconds_to_datetime(NewTimeSecs).
-module(eknife_time).

%% We don't want warnings about the use of erlang:now/0 in
%% this module.
-compile(nowarn_deprecated_function).
%%
%% We don't use
%%   -compile({nowarn_deprecated_function, [{erlang, now, 0}]}).
%% since this will produce warnings when compiled on systems
%% where it has not yet been deprecated.
%%

-export([monotonic_time/0,
    getTimestamp/0,
    get_local_time/0,
    msToDate/1,%%时间戳转成年月日
    msToDateFull/1,%%时间戳转成年月日时分秒
    dateToSec/1,%%时间转成时间戳
    dayToSec/1, %%日期转化为时间戳
    time_format/1, %% 时间格式化
    time_diff/2, %% 计算时间差
    second_diff_tomorrow/0, %% 距离明天凌晨的时间差
    second_diff_datetime/1,
    second_diff_datetime/2,
    monotonic_time/1,
    system_time/0,
    system_time/1,
    os_system_time/0,
    os_system_time/1,
    time_offset/0,
    time_offset/1,
    convert_time_unit/3,
    timestamp/0,
    unique_timestamp/0,
    unique_integer/0,
    unique_integer/1,
    monitor/2,
    system_info/1,
    system_flag/2]).

getTimestamp() ->
    {A, B, _} = os:timestamp(),
    A * 1000000 + B.

time_diff(DateTime1, DateTime2) ->
    calendar:time_difference(DateTime1, DateTime2).

time_format({H, M, S}) ->
    TimeString = lists:flatten(io_lib:format("~2..0B~2..0B~2..0B", [H, M, S])),
    erlang:list_to_binary(TimeString).

%% 指定日期的下一天的凌晨1秒的时候
tomorrow(Date) ->
    {eknife_date:shift(Date, 1, days), {0, 0, 1}}.
%% 距离明天早晨的时间差
second_diff_tomorrow() ->
    Date = date(),
    Now = {Date, time()},
    Tomorrow = tomorrow(Date),
    second_diff_datetime(Now, Tomorrow).

%% 计算datetime之间相差的秒数
second_diff_datetime(DateTime) ->
    second_diff_datetime({date(), time()}, DateTime).
second_diff_datetime(DateTime1, DateTime2) ->
    %% 时间差
    {Day, {H, M, S}} = eknife_time:time_diff(DateTime1, DateTime2),
    Day * 24 * 60 * 60 + calendar:time_to_seconds({H, M, S}).


%%获取当前日期的年月日
get_local_time() ->
    {{Y, M, D}, {_, _, _}} = calendar:local_time(),
    erlang:list_to_binary(fill_zero(Y, 4) ++ fill_zero(M, 2) ++ fill_zero(D, 2)).

fill_zero(N, Width) ->
    left_fill(N, Width, $0).

left_fill(N, Width, Fill) when is_integer(N) ->
    left_fill(integer_to_list(N), Width, Fill);
left_fill(N, Width, _Fill) when length(N) >= Width ->
    N;
left_fill(N, Width, Fill) ->
    left_fill([Fill | N], Width, Fill).

%%时间戳转成年月日
%%秒级的单位
msToDate(DaSeconds) ->
    BaseDate = calendar:datetime_to_gregorian_seconds({{1970, 1, 1}, {8, 0, 0}}),
    Seconds = BaseDate + DaSeconds,
    {{Y, M, D}, _Time} = calendar:gregorian_seconds_to_datetime(Seconds),
    erlang:list_to_binary(fill_zero(Y, 4) ++ fill_zero(M, 2) ++ fill_zero(D, 2)).
%%时间戳转成年月日
%%秒级的单位
msToDateFull(DaSeconds) ->
    BaseDate = calendar:datetime_to_gregorian_seconds({{1970, 1, 1}, {8, 0, 0}}),
    Seconds = BaseDate + DaSeconds,
    {Date, Time} = calendar:gregorian_seconds_to_datetime(Seconds),
    {Date, Time}.
%%时间转成时间戳
%%格式{{2017,12,18},{20,19,12}} 年月日时分秒
dateToSec(DateTime) ->
    calendar:datetime_to_gregorian_seconds(DateTime) -
        calendar:datetime_to_gregorian_seconds({{1970, 1, 1}, {8, 0, 0}}).

%% 日期转化为时间戳
dayToSec(Date) ->
    dateToSec({Date, {0, 0, 0}}).

-ifdef(NEED_TIME_FALLBACKS).
monotonic_time() ->
    erlang_system_time_fallback().

monotonic_time(Unit) ->
    STime = erlang_system_time_fallback(),
    convert_time_unit_fallback(STime, native, Unit).

system_time() ->
    erlang_system_time_fallback().

system_time(Unit) ->
    STime = erlang_system_time_fallback(),
    convert_time_unit_fallback(STime, native, Unit).

os_system_time() ->
    os_system_time_fallback().

os_system_time(Unit) ->
    STime = os_system_time_fallback(),
    try
        convert_time_unit_fallback(STime, native, Unit)
    catch
        error:bad_time_unit -> erlang:error(badarg, [Unit])
    end.

time_offset() ->
    %% Erlang system time and Erlang monotonic
    %% time are always aligned
    0.

time_offset(Unit) ->
    _ = integer_time_unit(Unit),
    %% Erlang system time and Erlang monotonic
    %% time are always aligned
    0.

convert_time_unit(Time, FromUnit, ToUnit) ->
    try
        convert_time_unit_fallback(Time, FromUnit, ToUnit)
    catch
        _:_ ->
            erlang:error(badarg, [Time, FromUnit, ToUnit])
    end.

timestamp() ->
    erlang:now().

unique_timestamp() ->
    erlang:now().

unique_integer() ->
    {MS, S, US} = erlang:now(),
    (MS * 1000000 + S) * 1000000 + US.

unique_integer(Modifiers) ->
    case is_valid_modifier_list(Modifiers) of
        true ->
            %% now() converted to an integer
            %% fullfill the requirements of
            %% all modifiers: unique, positive,
            %% and monotonic...
            {MS, S, US} = erlang:now(),
            (MS * 1000000 + S) * 1000000 + US;
        false ->
            erlang:error(badarg, [Modifiers])
    end.

monitor(Type, Item) ->
    try
        erlang:monitor(Type, Item)
    catch
        error:Error ->
            case {Error, Type, Item} of
                {badarg, time_offset, clock_service} ->
                    %% Time offset is final and will never change.
                    %% Return a dummy reference, there will never
                    %% be any need for 'CHANGE' messages...
                    make_ref();
                _ ->
                    erlang:error(Error, [Type, Item])
            end
    end.

system_info(Item) ->
    try
        erlang:system_info(Item)
    catch
        error:badarg ->
            case Item of
                time_correction ->
                    case erlang:system_info(tolerant_timeofday) of
                        enabled -> true;
                        disabled -> false
                    end;
                time_warp_mode ->
                    no_time_warp;
                time_offset ->
                    final;
                NotSupArg when NotSupArg == os_monotonic_time_source;
                    NotSupArg == os_system_time_source;
                    NotSupArg == start_time;
                    NotSupArg == end_time ->
                    %% Cannot emulate this...
                    erlang:error(notsup, [NotSupArg]);
                _ ->
                    erlang:error(badarg, [Item])
            end;
        error:Error ->
            erlang:error(Error, [Item])
    end.

system_flag(Flag, Value) ->
    try
        erlang:system_flag(Flag, Value)
    catch
        error:Error ->
            case {Error, Flag, Value} of
                {badarg, time_offset, finalize} ->
                    %% Time offset is final
                    final;
                _ ->
                    erlang:error(Error, [Flag, Value])
            end
    end.

%%
%% Internal functions
%%

integer_time_unit(native) -> 1000 * 1000;
integer_time_unit(nano_seconds) -> 1000 * 1000 * 1000;
integer_time_unit(micro_seconds) -> 1000 * 1000;
integer_time_unit(milli_seconds) -> 1000;
integer_time_unit(seconds) -> 1;
integer_time_unit(I) when is_integer(I), I > 0 -> I;
integer_time_unit(BadRes) -> erlang:error(badarg, [BadRes]).

erlang_system_time_fallback() ->
    {MS, S, US} = erlang:now(),
    (MS * 1000000 + S) * 1000000 + US.

os_system_time_fallback() ->
    {MS, S, US} = os:timestamp(),
    (MS * 1000000 + S) * 1000000 + US.

convert_time_unit_fallback(Time, FromUnit, ToUnit) ->
    FU = integer_time_unit(FromUnit),
    TU = integer_time_unit(ToUnit),
    case Time < 0 of
        true -> TU * Time - (FU - 1);
        false -> TU * Time
    end div FU.

is_valid_modifier_list([positive | Ms]) ->
    is_valid_modifier_list(Ms);
is_valid_modifier_list([monotonic | Ms]) ->
    is_valid_modifier_list(Ms);
is_valid_modifier_list([]) ->
    true;
is_valid_modifier_list(_) ->
    false.
-else.
monotonic_time() ->
    erlang:monotonic_time().

monotonic_time(Unit) ->
    erlang:monotonic_time(Unit).

system_time() ->
    erlang:system_time().

system_time(Unit) ->
    erlang:system_time(Unit).

os_system_time() ->
    os:system_time().

os_system_time(Unit) ->
    os:system_time(Unit).

time_offset() ->
    erlang:time_offset().

time_offset(Unit) ->
    erlang:time_offset(Unit).

convert_time_unit(Time, FromUnit, ToUnit) ->
    erlang:convert_time_unit(Time, FromUnit, ToUnit).

timestamp() ->
    erlang:timestamp().

unique_timestamp() ->
    {MS, S, _} = erlang:timestamp(),
    {MS, S, erlang:unique_integer([positive, monotonic])}.

unique_integer() ->
    erlang:unique_integer().

unique_integer(Modifiers) ->
    erlang:unique_integer(Modifiers).

monitor(Type, Item) ->
    erlang:monitor(Type, Item).

system_info(Item) ->
    erlang:system_info(Item).

system_flag(Flag, Value) ->
    erlang:system_flag(Flag, Value).

-endif.

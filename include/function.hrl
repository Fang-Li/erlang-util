-define(IF(C, T, F), (case (C) of true -> (T); false -> (F) end)).
-define(IFDO(C, T), (case (C) of true -> (T); false -> nothing end)).

%%截取小数位数
-define(DECIMAL_DIGITS(Number, Digits), (round(Number * math:pow(10, Digits)) / math:pow(10, Digits))).

%%向上取整函数
-define(CEIL(FloatNum),
    if
        FloatNum - erlang:trunc(FloatNum) > 0 ->
            erlang:trunc(FloatNum) + 1;
        true ->
            erlang:trunc(FloatNum)
    end
).
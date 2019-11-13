%%%-------------------------------------------------------------------
%%% @author lifang
%%% @copyright (C) 2019, <WISH START>
%%% @doc
%%% 
%%% @end
%%% Created : 2019-09-18 22:50
%%%-------------------------------------------------------------------
-module(eknife_math).

-compile(export_all).

%% API exports
-export([is_even/1, is_odd/1, floor/1, ceiling/1, is_power_of_two/1]).
-export([is_perfect_square/1, modulus/2, remainder/2, power_of_two/1]).
-export([ceiling_to_power_of_two/1, gcd/1, gcd/2, lcm/1, lcm/2]).


%%====================================================================
%% API functions
%%====================================================================
is_even(X) when is_number(X) ->
    (X band 2#1) == 2#0.


is_odd(X) when is_number(X) ->
    (X band 2#1) == 2#1.


%% Erlang doesn't provide a floor and ceiling funtions.
%% The following implementations are possible by implementing the trunc function.
%% https://erlangcentral.org/wiki/index.php?title=Floating_Point_Rounding

floor(X) when X < 0 ->
    E = trunc(X),
    case X - E == 0 of
        true -> E;
        false -> E - 1
    end;
floor(X) ->
    trunc(X).


ceiling(X) when X < 0 ->
    trunc(X);
ceiling(X) ->
    E = trunc(X),
    case X - E == 0 of
        true -> E;
        false -> E + 1
    end.


% Check if the given value is a perfect power of two

is_power_of_two(X) when X > 0 ->
    (X band (X - 1)) == 2#0.


% Check if the given integer value is a perfect square

is_perfect_square(X) when X < 0 ->
    false;
is_perfect_square(X) ->
    E = X band 16#F,
    case E of
        E when E > 9 ->
            false;
        E when E == 0;E == 1;E == 4;E == 9 ->
            Z = trunc(math:sqrt(X) + 0.5),
            (Z * Z) == X;
        _ ->
            false
    end.


%% Congruent Modulo
%% http://math.stackexchange.com/questions/2991/not-understanding-simple-modulus-congruency
%% https://blogs.msdn.microsoft.com/ericlippert/2011/12/05/whats-the-difference-remainder-vs-modulus/

modulus(Dividend, Divisor) when is_number(Dividend), is_number(Divisor) ->
    ((Dividend rem Divisor) + Divisor) rem Divisor.


remainder(Dividend, Divisor) when is_number(Dividend), is_number(Divisor) ->
    Dividend rem Divisor.


% Raises two over the given value

power_of_two(X) when X > 0 ->
    1 bsl X.


% Get the closest larger power of two

ceiling_to_power_of_two(X) ->
    to_power_of_two(X - 1, 1).


fraction(Numerators, Denominators, DecimalNumber) ->
    Decimal = fraction(Numerators, Denominators),
    float(Decimal, DecimalNumber).


%% 分数求和,参数为拆分后的分子列表和分母列表
fraction(Numerators, Denominators) ->
    LCM = lcm(Denominators),
    {NumeratorSum, _} = do_fraction(Numerators, Denominators, LCM),
    NumeratorSum / LCM.

%% 分母通分后的分子和
do_fraction(Numerators, Denominators, LCM) ->
    NumeratorSum = reduction_to_common_denominator(Numerators, Denominators, LCM, 0),
    {NumeratorSum, LCM}.

%% 分母通分后的分子和
reduction_to_common_denominator([], [], _LCM, Sum) ->
    Sum;
reduction_to_common_denominator([Numerator | Numerators], [Denominator | Denominators], LCM, Sum) ->
    Multiple = LCM div Denominator,
    MultipleNumerator = Numerator * Multiple,
    reduction_to_common_denominator(Numerators, Denominators, LCM, MultipleNumerator + Sum).


%% Greatest Common Divisor

gcd(X, Y) when Y == 0 ->
    abs(X);
gcd(X, Y) ->
    gcd(Y, X rem Y).


gcd(Nums) when is_list(Nums), length(Nums) == 0 ->
    0;
gcd(Nums) when is_list(Nums) ->
    G = abs(hd(Nums)),
    gcd(tl(Nums), G, 0).


%% Least Common Multiple

lcm(X, Y) when X == 0; Y == 0 ->
    0;
lcm(X, Y) ->
    abs((X div gcd(X, Y)) * Y).


lcm(Nums) when is_list(Nums), size(Nums) == 0 ->
    1;
lcm(Nums) when is_list(Nums) ->
    L = abs(hd(Nums)),
    lcm(tl(Nums), L, 0).


%%====================================================================
%% Internal functions
%%====================================================================

gcd(Nums, Gcd, _) when length(Nums) > 0, Gcd > 1 ->
    G = gcd(Gcd, hd(Nums)),
    gcd(tl(Nums), G, 0);
gcd(Nums, Gcd, _) when length(Nums) == 0 ->
    Gcd.


lcm(Nums, Lcm, _) when length(Nums) > 0 ->
    L = lcm(Lcm, hd(Nums)),
    lcm(tl(Nums), L, 0);
lcm(Nums, Lcm, _) when length(Nums) == 0 ->
    Lcm.


to_power_of_two(E, P) when P =< 32 ->
    to_power_of_two(E bor (E bsr P), P + P);
to_power_of_two(E, P) when P > 32 ->
    E + 1.

%% 调整浮点数精度,第一种方法,性能更好
float(Number, X) ->
    N = math:pow(10, X),
    round(Number * N) / N.

%% 调整浮点数精度,第二种方法,可做参考学习
float2(Number, X) ->
    X2 = integer_to_list(X),
    Number2 = io_lib:format("~." ++ X2 ++ "f", [Number]),
    list_to_float(hd(Number2)).
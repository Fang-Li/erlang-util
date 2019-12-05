%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% 不规则图形的等分坐标
%%% @end
%%%-------------------------------------------------------------------
-module(seperate).

-compile(export_all).
-export([
    perimeter/1,
    get_coodinate/2,
    test/0,
    test2/0,
    test3/0,
    test4/0
]).


%% 默认测试数据,{x坐标,y坐标}
init() ->
    [
        {1, 1},
        {1, 2},
        {3, 2},
        {3, 4},
        {6, 4},
        {6, 1},
        {1, 1}
    ].

%% 获取定长值
get_k(Coordinates, N) ->
    perimeter(Coordinates) div N.

%% 求周长
perimeter(Coordinates) ->
    perimeter(Coordinates, 0).

perimeter([C1, C2 | Tail], Perimeter) ->
    Perimeter2 = line_length(C1, C2) + Perimeter,
    perimeter([C2 | Tail], Perimeter2);
perimeter(_, Perimeter) ->
    Perimeter.

%% 线长
line_length({X1, Y1}, {X2, Y2}) ->
    abs(X2 - X1) + abs(Y2 - Y1).

%% 获取每隔k距离的位置的坐标
get_coodinate(Coordinates, N) ->
    K = get_k(Coordinates, N),
    get_coodinate(Coordinates, K, _AlreadyLen = 0, _CKs = []).

get_coodinate([C1, C2 | Tail], K, AlreadyLen, CKs) ->
    LineLen = line_length(C1, C2),
    if
        (LineLen + AlreadyLen) == K ->
            get_coodinate([C2 | Tail], K, _AlreadyLen = 0, CKs ++ [C2]);
        (LineLen + AlreadyLen) > K ->
            Ck = get_ck(C1, C2, LineLen, AlreadyLen, K),
            get_coodinate([Ck, C2 | Tail], K, _AlreadyLen = 0, CKs ++ [Ck]);
        (LineLen + AlreadyLen) < K ->
            get_coodinate([C2 | Tail], K, LineLen + AlreadyLen, CKs)
    end;
get_coodinate(_, _K, _AlreayLen, Cks) ->
    Cks.


%% 工具:计算指定的坐标值
%% LineLen: 两点之间的距离,AlreadyLen是上面剩余不够K的距离,K是固定的长度值
get_ck(C1, C2, LineLen, AlreadyLen, K) ->
    AlreadyLen2 = (LineLen + AlreadyLen) - K,
    MissingLen = LineLen - AlreadyLen2,
    {X, Y} = C1,
    case get_axis_direction(C1, C2) of
        x ->
            {X + MissingLen, Y};
        x_ ->
            {X - MissingLen, Y};
        y ->
            {X, Y + MissingLen};
        _ ->
            {X, Y - MissingLen}
    end.

%% 获取两个点的坐标轴的走向
get_axis_direction({X1, Y1}, {X2, Y2}) ->
    case X1 == X2 of
        true ->
            case Y1 >= Y2 of
                true ->
                    y_;
                _ ->
                    y
            end;
        _ ->
            case X1 >= X2 of
                true ->
                    x_;
                _ ->
                    x
            end
    end.

%% K可以是任意数,只有是周长的因数时,才能够平均分配
test() ->
    seperate:get_coodinate(seperate:init(), 2).

test2() ->
    seperate:get_coodinate(seperate:init(), 4).

test3() ->
    seperate:get_coodinate(seperate:init(), 8).

test4() ->
    seperate:get_coodinate(seperate:init(), 16).
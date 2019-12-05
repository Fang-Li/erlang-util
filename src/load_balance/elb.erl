%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% 
%%% @end
%%%-------------------------------------------------------------------
-module(elb).

-compile(export_all).
-define(Tab, ?MODULE).
-define(Global, global).
%% 进程字典存储索引状态
%% random获取随机状态

%% 两种的效率差别,用来做负载的状态策略

set(Index) ->
    erlang:put(?MODULE, Index).

got() ->
    case get(?MODULE) of
        undefined ->
            1;
        Index ->
            Index
    end.

got_ets() ->
    case ets:info(?Tab) of
        undefined ->
            init_ets(),
            1;
        _ ->
            [{_, Index}] = ets:lookup(?Tab, ?Global),
            Index
    end.

init_ets() ->
    ets:new(?Tab, [set, public, named_table, {read_concurrency, true}, {write_concurrency, true}]),
    ets:insert(?Tab, {?Global, 1}).

set_ets(Index) ->
    case ets:info(?Tab) of
        undefined ->
            init_ets();
        _ ->
            ets:insert(?Tab, {?Global, Index})
    end.

index(Len) ->
    Index = got(),
    if Index < Len ->
        set(Index + 1);
        true ->
            set(1)
    end.

index2(Len) ->
    Index = got(),
    set((Index rem Len) + 1).

index3(Len) ->
    Index = got_ets(),
    if Index < Len ->
        set_ets(Index + 1);
        true ->
            set_ets(1)
    end.

random(Len) ->
    rand:uniform(Len).

test1() ->
    performance_test:main(100, 100000, fun index/1, [], 3).

test2() ->
    performance_test:main(100, 100000, fun index2/1, 18, 3).

test3() ->
    performance_test:main(100, 100000, fun index3/1, 18, 3).

test4() ->
    performance_test:main(100, 100000, fun random/1, 18, 3).
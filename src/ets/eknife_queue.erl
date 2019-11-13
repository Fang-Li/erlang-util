%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% ets 实现队列
%%% @end
%%%-------------------------------------------------------------------
-module(eknife_queue).

-compile(export_all).
-include("include/function.hrl").
-compile(export_all).
-record(ets, {max_size, size, push_index, pull_index, ets}).

new(MaxSize) ->
    Table = ets:new(buffer, [named_table]),
    lists:foreach(
        fun(Seq) ->
            ets:insert(Table, {Seq, nil})
        end, lists:seq(0, MaxSize - 1)),
    #ets{
        max_size = MaxSize,
        size = 0,
        push_index = 0,
        pull_index = 0,
        ets = Table
    }.

size(Ets) ->
    Ets#ets.size.

push(Ets, Msg) ->
    ets:update_element(Ets#ets.ets, Ets#ets.push_index, {2, Msg}),
    NextPushIndex = Ets#ets.push_index + 1 rem Ets#ets.max_size,
    NextPullIndex = ?IF(Ets#ets.size == Ets#ets.max_size, NextPushIndex, Ets#ets.pull_index),

    Ets#ets{
        size = min(Ets#ets.size + 1, Ets#ets.max_size),
        push_index = NextPushIndex,
        pull_index = NextPullIndex
    }.

pull(#ets{size = 0}) ->
    {error, empty};

pull(#ets{pull_index = PullIndex} = Ets) ->
    {ok,
        {
            ets:lookup_element(Ets#ets.ets, PullIndex, 2),
            Ets#ets{size = Ets#ets.size - 1,
                pull_index = PullIndex + 1 rem Ets#ets.max_size}
        }
    }.


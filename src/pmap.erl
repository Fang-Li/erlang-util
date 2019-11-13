%%%-------------------------------------------------------------------
%%% @author lifang
%%% @copyright (C) 2019, <WISH START>
%%% @doc
%%% MapReduce的主要原理是将一个数据集上的计算分发到许多单独的进程上(map)，然后收集它们的结果(reduce)。
%%% 在Erlang里实现MapReduce非常细节也十分简单，例如Erlang的作者Joe Armstrong发表了一段代码来表示MapReduce
%%% @end
%%% Created : 2019-09-19 14:35
%%%-------------------------------------------------------------------
-module(pmap).

-compile(export_all).

pmap(F, L) ->
    S = self(),
    Pids = lists:map(fun(I) ->
        spawn(fun() -> do_fun(S, F, I) end)
                     end, L),
    gather(Pids).

gather([H|T]) ->
    receive
        {H, Result} -> [Result|gather(T)]
    end;
gather([]) ->
    [].

do_fun(Parent, F, I) ->
    Parent ! {self(), (catch F(I))}.
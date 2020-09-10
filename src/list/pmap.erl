%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% map_reduce 的主要原理是将一个数据集上的计算分发到许多单独的进程上(map)，然后收集它们的结果(reduce)。
%%% 结果是按顺序收集的，因此单轮计算的执行时间最多与最慢实例的执行时间一样快
%%% @end
%%%-------------------------------------------------------------------
-module(pmap).

-compile(export_all).

pmap(F, L) ->
    S = self(),
    Pids = lists:map(
        fun(I) ->
            spawn(fun() -> do_fun(S, F, I) end)
        end, L),
    gather(Pids).

gather([H | T]) ->
    io:format("if receive ~p lately.. ~n",[H]),
    receive
        {H, Result} -> [Result | gather(T)]
    end;
gather([]) ->
    [].

do_fun(Parent, F, I) ->
    io:format("if send ~p first.. ~n",[I]),
    Parent ! {self(), (catch F(I))}.

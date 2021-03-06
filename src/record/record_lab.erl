%%%-------------------------------------------------------------------
%%% @author lifang
%%% @copyright (C) 2019, <Wish Start>
%%% @doc
%%%
%%% @end
%%% Created : 25. May 2019 4:12 PM
%%%-------------------------------------------------------------------
-module(record_lab).
-author("lifang").

-compile(export_all).



-record(state, {louhu_pai :: integer()}).

%% dialyzer record_lab.erl
% record_lab.erl:21: Function lab/0 has no local return
% record_lab.erl:22: Record construction #state{louhu_pai::[]} violates the declared type of field louhu_pai::integer()
lab() ->
    #state{louhu_pai = ""},
    io:format("veritify default value .. ~p~n", [#state{}]),
    #state{}.


pretty_print(Val) ->
    io_lib_pretty:print(Val, fun rec_def_fun/2).

rec_def_fun(Tag, N) ->
    Ret = recordfields:get(Tag),
    case Ret =/= [] andalso length(Ret) =:= N of
        true -> Ret;
        false -> no
    end.
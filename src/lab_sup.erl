-module(lab_sup).
-behaviour(gen_server).
-compile(export_all).
start() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
init([])->
    process_flag(trap_exit, true),
    gen_server:start_link({local, s1}, lab, [], []),
    gen_server:start_link({local, s2}, lab, [], []),
    gen_server:start_link({local, s3}, lab, [], []),
    gen_server:start_link({local, s4}, lab, [], []),
    {ok, {}}.

handle_info(Info, State) -> 
    io:format("~p~n",[Info]),
    {noreply, State}.
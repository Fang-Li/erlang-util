-module(encoding).
-compile(export_all).
-define(DBGFSM, p1_fsm).
-ifdef(DBGFSM).
-define(FSMOPTS, [{debug, [trace]}]).
-else.
-define(FSMOPTS, []).
-endif.

test() ->
  io:format("~p~n",[?FSMOPTS]).
  
io() ->

    io:format("~ts~n", ["中国"]),
    % io:format("~ts~n", [list_to_binary("中国")]),

  io:format("~ts~n", [[228,184,173,229,155,189]]),
  io:format("~ts~n", [<<228,184,173,229,155,189>>]).

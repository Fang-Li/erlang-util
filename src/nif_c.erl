-module(nif_c).
-export([init/0, getloadavg_ex/0, b/1,c/0]).
-compile(export_all).
-on_load(init/0).

init() ->
   erlang:load_nif("./a", 0).

getloadavg_ex() ->
   "NIF library not loaded".

%%b() -> io:format("~p~n",[getloadavg_ex()]).
b(Arg) ->
  "NIF library not loaded".

c() -> io:format("~p~n",[b(<<"1">>)]).


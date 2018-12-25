-module(variable).
-compile(export_all).

start() ->
	erlang:put(?MODULE, ?MODULE:module_info()).
test() ->
	erlang:get(?MODULE).

test2() ->
	?MODULE:module_info().
test3(Args) ->
	Args.

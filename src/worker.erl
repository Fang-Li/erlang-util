-module(worker).
-compile(export_all).
-behaviour(gen_server).
-record(state,{}).

start() ->
  gen_server:start({local,worker},worker,[],[]).
init(_Args) ->
  State = #state{},
  {ok,State}.

handle_call(Args,_From,State) ->
  io:format("~p:handle_call line:~p args = ~p~n",[?MODULE,?LINE,Args]),
	{reply,Args,State}.
handle_info(Args,State) ->
  io:format("~p:handle_info line:~p args = ~p~n",[?MODULE,?LINE,Args]),
	case Args of
	  {ykt,Size,Count} -> packet_ykt:accept({Size,Count});
		{ypt,Size,Count} -> packet_ypt:accept({Size,Count})
	end,
	{noreply,State}.
handle_cast(_Args,State) ->
  {noreply,State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.
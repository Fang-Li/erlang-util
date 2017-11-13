-module(my_gen_server2).
-compile(export_all).
-behaviour(gen_server).

start() ->
  gen_server:start( {local, hello} ,my_gen_server,[a],[]).
init(A) ->
  io:format("A .. ~p~n",[A]),
  {ok,[]}.
handle_call(_,_,_) ->
  A = "call",
  io:format("A .. ~p~n",[A]),
	timer:sleep(50000000),
	Hello = gen_server:call(hello,a),
	io:format("Hello .. ~p~n",[Hello]),
  {reply, hello, []}.
handle_cast(_,_) ->
  A = "cast",
  io:format("A .. ~p~n",[A]),
  {noreply,[]}.
handle_info(_,_) ->
  A = "info",
  io:format("A .. ~p~n",[A]),
	try 
	  gen_server:call(hello,a,5)
	catch 
	  E:R->
		  Err = erlang:get_stacktrace(),
      io:format(" gen_server:call ~p, Reason=~p~n~p",[E,R,Err])
  end,
	% io:format("Hello .. ~p~n",["xxxxxxxxxxxxxxx"]),
	% io:format("Hello .. ~p~n",[Hello]),
  {noreply,[]}.
terminate(_,_) ->
  A = "terminate",
  io:format("A .. ~p~n",[A]),
  ok.
code_change(_,_,_) ->
  A = "code_change",
  io:format("A .. ~p~n",[A]),
  {ok,[]}.
  
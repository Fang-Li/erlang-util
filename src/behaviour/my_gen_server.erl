-module(my_gen_server).
-compile(export_all).
-behaviour(gen_server).

start() ->
  gen_server:start( {local, proname} ,my_gen_server,[a],[]).
init(A) ->
  self() ! aa,
  io:format("A .. ~p~n",[A]),
  {ok,[]}.
handle_call(_,_,_) ->
  A = "call",
  io:format("A .. ~p~n",[A]),
  {reply, hello, []}.
handle_cast(bb,_State) ->
    %%A = "cast",
    io:format("A .. ~p~n",[bb]),
    {reply,[aa],[]};
handle_cast(Data,_State) ->
  %%A = "cast",
  loop(), %% 当进程一直在loop时，是不会在处理其他消息的，但是会接收到信箱待处理的
  io:format("A .. ~p~n",[Data]),
  {noreply,[]}.

handle_info(aa,_) ->
  io:format("A .. ~p~n",[aa]),
  %%erlang:send_after(3000,self(),aa),
  %%Config = [ {host,                  "1.1.1.1"}
  %%, {port,                  22}
  %%, {user,                  "foo"}
  %%, {password,              "bar"}
  %%, {timeout,               5000}
  %%, {connect_timeout,       5000}
  %%, {user_interaction,      false}
  %%, {silently_accept_hosts, true}
  %%, {retries,               2}
  %%],
  %%%% list a dir
  %%Res = sftp_utils:list_dir("/tmp", Config),
  %%%Res = ssh:connect("1.1.1.1",22,
  %%%[{silently_accept_hosts,true},
  %%% {connect_timeout,5000},
  %%% {password,"bar"},
  %%% {user,"foo"}],
  %%%5000),
  %%Res = gen_tcp:connect("1.1.1.1", 22, [{active,false},inet], 5000),  
  io:format("A .. ~p~n",[aa]),
  {noreply,[]};
handle_info(A,_) ->
  io:format("info .. ~p~n",[A]),
  {noreply,[]}.

terminate(_,_) ->
  A = "terminate",
  io:format("A .. ~p~n",[A]),
  ok.
code_change(_,_,_) ->
  A = "code_change",
  io:format("A .. ~p~n",[A]),
  {ok,[]}.
  
loop() ->
  loop().
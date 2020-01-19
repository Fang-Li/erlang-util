-module(server_demo).  
-export([start/0, rpc_call/2]).  
  
start() ->  
   Pid = spawn(fun() -> server_loop() end),  
   register(demo, Pid), %%注册进程名字  
   ok.  
  
server_loop() ->  
   receive  
      {msg, Pid, Msg} ->  
         io:format("receive msg ~p from pid ~p~n",[Msg, Pid]);  
      {rpc, Pid, Msg} ->  
         io:format("receive rpc ~p from pid ~p~n",[Msg, Pid])  
   end,  
   server_loop().  
      
rpc_call(Pid, Msg) ->  
   demo ! {rpc, Pid, Msg}. 
   
%% net_kernel:start(['node_1@127.0.0.1',longnames]).
%% erl -s server_demo start -hidden -name server@127.0.0.1 -setcookie 123456  
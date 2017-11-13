-module(client_demo).  
-export([start/0]).  
  
start() ->  
   ServerNode = 'server@127.0.0.1',  
   case net_kernel:connect(ServerNode) of  
      true ->  
         io:format("connect server success!"),  
         %% 第一种通信方式：发信息  
         {demo, ServerNode} ! {msg, self(), "hello world!"},  
         %% 第二种通信方式：远程调用  
         rpc:call(ServerNode, demo, rpc_call, [self(), "hello2!"]),  
         ok;  
     _ ->  
         io:format("connect server fail!")  
   end,  
   ok. 
   
%% erl -s client_demo start -hidden -name client@127.0.0.1 -setcookie 123456  
%% -module(app_lab).
%% -compile(export_all).
%% -behaviour(application).
%% start(_A,_B) ->
%%   Pid = spawn(fun()->timer:sleep(200000) end),
%%   {ok,Pid}.
%%   
%% stop(_R) ->
%%   ok.




-module(app_lab).  
  
-behaviour(application).  
  
-export([start/2, stop/1]).  
  
start(_Type, StartArgs) ->  
    io:format("test app start~n"),  
    case app_lab_sup:start_link(StartArgs) of  
        {ok, Pid} ->  
            {ok, Pid};  
        Error ->  
            Error  
    end.  
  
stop(_State) ->  
    ok.  
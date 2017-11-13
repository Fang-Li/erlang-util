-module(lab_link).  
-export([start/0]).  
  
start() ->  
    Pid = spawn(fun() ->loop() end),  
    Pid2 = spawn(fun() ->loop_link(Pid) end),  
    Pid3 = spawn(fun() ->loop_monitor(Pid) end), 
    io:format("Pid ~p~nPid2 ~p~nPid3 ~p~n", [Pid,Pid2,Pid3]).  
  
loop_link(Pid) ->  
    process_flag(trap_exit, true),  
    erlang:link(Pid),  
    receive  
        Msg ->  
            io:format("link pid exit: ~p~n", [Msg])  
    end.  

loop_monitor(Pid) ->  
    _MonitorRef = erlang:monitor(process, Pid),  
    receive  
        Msg ->  
            io:format("monitor pid exit: ~p~n", [Msg])  
    end.  

loop() ->  
    process_flag(trap_exit, true),  
    receive  
        Msg ->  
            io:format("pid2/3 exit: ~p~n", [Msg])  
    end. 

%% 1> test:start().  
%% Pid <0.63.0>  
%% Pid2 <0.64.0>  
%% ok  
%% %% 杀掉Pid进程，进程Pid2收到通知  
%% 2> exit(pid(0,63,0),kill).  
%% pid exit: {'EXIT',<0.63.0>,killed}  
%% true  
%%   
%% 3> test:start().  
%% Pid <0.67.0>  
%% Pid2 <0.68.0>  
%% ok  
%% %% 杀掉Pid2进程，进程Pid收到通知  
%% 4> exit(pid(0,68,0),kill).  
%% pid2 exit: {'EXIT',<0.68.0>,killed}  
%% true      
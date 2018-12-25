-module(performance_test).
-compile(export_all).

%% workers.
main(_N_Pro, _N_Times, _WorkFun, _Arg, 0) ->
    over;
main(N_Pro, N_Times, WorkFun, Arg, LoopTime) ->
    %%     error_logger:logfile({open,"./tmp_test.log"}),
    MainId =  self(),
    P_Times =  N_Times div N_Pro,
    Collector = spawn(fun()->collect(MainId,N_Pro,0,0,0)end),
    Workers = [spawn(?MODULE,worker,[Collector,WorkFun, P_Times])||_I<-lists:seq(1,N_Pro)],
    Start = now(),
    
    [Worker!{start, Arg}||Worker<-Workers],
    receive
        {all_done, TotalSuc, TotalFail} ->
            Time = timer:now_diff(now(), Start) / 1000,
            io:format("time consumed : ~p ms  hit per ms : ~p~n total successed :~p total failed :~p ~n",
                                [Time, N_Times/Time, TotalSuc, TotalFail]),
            [exit(Worker,kill)||Worker<-Workers],
            case LoopTime of
                infinity->
                    main(N_Pro,N_Times, WorkFun, Arg,LoopTime);
                _ ->
                    main(N_Pro,N_Times, WorkFun, Arg, LoopTime-1)
            end;
        _ ->
            go_on
    end.

worker(Collector,WorkFun, Times) ->
    receive
        {start, Arg} ->
            do_job(Collector,Times, WorkFun, Arg, 0, 0)
    end.

do_job(Collector, 0, _WorkFun, _Arg, Suc, Fail) ->
    %    io:format("in job worker ~p done, suc num : ~p , fail num :~p ~n",[self(), Suc, Fail]),
    Collector!{done, self(), Suc, Fail};
do_job(Collector, Times, WorkFun, Arg, Suc, Fail) ->
    _Res = WorkFun(Arg),
%%     error_logger:format("the res : ~p~n", [_Res]),
    do_job(Collector, Times - 1, WorkFun, Arg, Suc + 1, Fail).



collect(MainId, N_Pro, N_Finished, TotalSuc, TotalFail) when N_Pro==N_Finished ->
    MainId ! {all_done, TotalSuc, TotalFail} ;

collect(MainId, N_Pro, N_Finished, TotalSuc, TotalFail) ->
    receive
        {done, _Worker, Suc, Fail} ->
            %            io:format("worker ~p done, suc num : ~p , fail num :~p finished : ~p ~n",[Worker, Suc, Fail,N_Finished+1]),
            collect(MainId, N_Pro, N_Finished +1, TotalSuc+Suc, TotalFail+Fail)
    end.

%% test api.

simple_test(ProNO, TotalTimes, LoopTimes) ->
    List = [1,2,3,4,5,6,7,8,9,0],
    main(ProNO, TotalTimes, fun length/1, List, LoopTimes).

%% n个Fun运行total次,循环Loop次    
main({ProcessNum,TotalTimes,LoopTimes},{Fun,Args}) ->
	main(ProcessNum,TotalTimes,Fun,Args,LoopTimes).

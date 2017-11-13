-module(packet_ypt).
-compile(export_all).
-behaviour(gen_server).


-define(DURATION, 10 * 1000). %% 10秒
-define(MAX_SIZE, 3 ).          
-define(MAX_COUNT,3).

-record(state,{
  size = 0,
  count = 0,
	status = waiting,
  timed_task = erlang:start_timer(?DURATION, self(), reset) %% 定时任务
  }).

accept(Args) ->
  State = gen_server:call(?MODULE,Args),
	io:format("~p:handle_call line:~p State = ~p~n",[?MODULE,?LINE,State]).
	
start() ->
  gen_server:start({local,packet_ypt},packet_ypt,[],[]).
init(_Args) ->
  State = #state{},
  {ok,State}.
handle_call({Size, Count}, _From, State) ->  
    %% io:format("~p~n",[{Size, Count}]),  
    State2 = #state{size = State#state.size + Size, count = State#state.count + Count},
    io:format(" size  = ~p~n count = ~p~n~n~n",[State2#state.size,State2#state.count]),
    
    case State2#state.size > ?MAX_SIZE of
      true -> 
          io:format(" 超出最大size，清空状态，重新开启定时任务 ...... ~n"),
          clear_timer(State#state.timed_task),
          State3 = #state{status = finish};
      _ ->
        case  State2#state.count > ?MAX_COUNT of
          true ->
            io:format(" 超出最大count，清空状态，重新开启定时任务 ...... ~n"),
            clear_timer(State#state.timed_task),
            State3 = #state{status = finish};
          _ ->
            State3 = State2
        end
    end,
    {reply,State3,State3};
   
handle_call(Args,_From,State) ->
  io:format("~p:handle_call line:~p args = ~p~n",[?MODULE,?LINE,Args]),
	{reply,Args,State}.
	
handle_info({timeout, TimerRef, reset}, State) ->
    case State#state.timed_task of
      TimerRef ->
        io:format(" 定时时间到，清空状态，重新开启定时任务 ...... ~n"),
        clear_timer(TimerRef),
        State2 = #state{status = finish};
      _ ->
        State2 = State
    end,
    io:format(" size  = ~p~n count = ~p~n~n~n",[State2#state.size,State2#state.count]),
    {noreply, State2};
    
handle_info(Args,State) ->
  io:format("~p:handle_info line:~p args = ~p~n",[?MODULE,?LINE,Args]),
	{noreply,State}.
handle_cast(_Args,State) ->
  {noreply,State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.


%% 清除定时任务
clear_timer(TimerRef) ->
  case TimerRef of
    undefined ->
      undefined;
    _ ->
      erlang:cancel_timer(TimerRef),
      ok
  end.
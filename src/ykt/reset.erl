-module(reset).
-compile(export_all).
-behaviour(gen_server).

-define(DURATION,15 * 1000 * 60). %%  15分钟
-define(DURATION_TEMP, 20 * 1000). %% 20秒

-define(MAX_SIZE,3).          
-define(MAX_COUNT,3).

-record(state,{
  size = 0,
  count = 0,
  % timed_task = erlang:send_after(?DURATION_TEMP, self(), reset) %% 定时任务
  timed_task = erlang:start_timer(?DURATION_TEMP, self(), reset) %% 定时任务
  }).



start() ->
  gen_server:start({local,?MODULE}, ?MODULE,[],[]).

init(Args) ->
  io:format("~p~n",[Args]),
  % TimerRef  = erlang:send_after(?DURATION_TEMP, self(), reset),
  {ok,#state{}}.
  
handle_call(_Msg, _, _) ->            
    {noreply,ok}.
    
handle_cast(_Msg, State) ->
    {noreply, State}.
    
handle_info({timeout, TimerRef, reset}, State) ->
    case State#state.timed_task of
      TimerRef ->
        io:format(" 定时时间到，清空状态，重新开启定时任务 ...... ~n"),
        clean_timer(TimerRef),
        State2 = #state{};
      _ ->
        %% 过期的reset消息，不予处理
        State2 = State,
        ok
    end,
    
    io:format(" size  = ~p~n count = ~p~n~n~n",[State2#state.size,State2#state.count]),
    {noreply, State2};
    
handle_info({Size, Count}, State) ->
    
    State2 = #state{size = State#state.size + Size,count = State#state.count + Count},
    io:format(" size  = ~p~n count = ~p~n~n~n",[State2#state.size,State2#state.count]),
    
    case State2#state.size > ?MAX_SIZE of
      true -> 
        io:format(" 超出最大size，清空状态，重新开启定时任务 ...... ~n"),
        clean_timer(State#state.timed_task),
        State3 = #state{};
      _ ->
        case  State2#state.count > ?MAX_COUNT of
          true ->
            io:format(" 超出最大count，清空状态，重新开启定时任务 ...... ~n"),
            clean_timer(State#state.timed_task),
            State3 = #state{};
          _ ->
            State3 = State2
        end
    end,
    {noreply, State3};
    
handle_info( _, State) ->
    {noreply, State}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
terminate(_Reason, State) ->
    ok.    
    
    
%% 清除定时任务
clean_timer(TimerRef) ->
  case TimerRef of
    undefined ->
      undefined;
    _ ->
      erlang:cancel_timer(TimerRef),
      ok
  end.
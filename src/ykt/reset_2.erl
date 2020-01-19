-module(reset_2).
-compile(export_all).
-behaviour(gen_server).

-define(DURATION,15 * 1000 * 60). %%  15分钟
-define(DURATION_TEMP, 20 * 1000). %% 20秒

-define(MAX_SIZE,1024 * 10 ).          
-define(MAX_COUNT,1000).

-record(stateypt,{
  size = 0,
  count = 0,
  % timed_task = erlang:send_after(?DURATION, self(), reset) %% 定时任务
  timed_task = erlang:start_timer(?DURATION_TEMP, self(), reset) %% 定时任务
  }).



start() ->
  gen_server:start({local,?MODULE}, ?MODULE,[],[]).

init(Args) ->
  io:format("~p~n",[Args]),
  % TimerRef  = erlang:send_after(?DURATION, self(), reset),
  {ok,#stateypt{}}.
  
  
handle_call({Size, Count}, _From, State) ->  
    %% io:format("~p~n",[{Size, Count}]),  
    State2 = #stateypt{size = State#stateypt.size + Size, count = State#stateypt.count + Count},
    io:format(" size  = ~p~n count = ~p~n~n~n",[State2#stateypt.size,State2#stateypt.count]),
    
    case State2#stateypt.size > ?MAX_SIZE of
      true -> 
        case lists:member(State#stateypt.size, ["0",0]) of
          true ->
            put(threeLimitypt,"1");
          false ->
             put(threeLimitypt,"0")
        end,
          io:format(" 超出最大size，清空状态，重新开启定时任务 ...... ~n"),
          %% ergmbs_yptConvert:yptConvert(),
          clean_timer(State#stateypt.timed_task),
          State3 = #stateypt{};
      _ ->
        case  State2#stateypt.count > ?MAX_COUNT of
          true ->
            case lists:member(State#stateypt.count, ["0",0]) of
              true ->
                put(threeLimitypt,"1");
              false ->
                put(threeLimitypt,"0")
            end,
            io:format(" 超出最大count，清空状态，重新开启定时任务 ...... ~n"),
            %% ergmbs_yptConvert:yptConvert(),
            clean_timer(State#stateypt.timed_task),
            State3 = #stateypt{};
          _ ->
            put(threeLimitypt,"1"),
            State3 = State2
        end
    end,
    {reply,State3,State3}.
    
handle_cast(_Msg, State) ->
    {noreply, State}.
    
handle_info({timeout, TimerRef, reset}, State) ->
    case State#stateypt.timed_task of
      TimerRef ->
        io:format(" 定时时间到，清空状态，重新开启定时任务 ...... ~n"),
        %% ergmbs_yptConvert:yptConvert(),
        clean_timer(TimerRef),
        put(threeLimitypt,"0"),
        State2 = #stateypt{};
      _ ->
        %% 过期的reset消息，不予处理
        State2 = State,
        put(threeLimitypt,"1"),
        ok
    end,
    
    io:format(" size  = ~p~n count = ~p~n~n~n",[State2#stateypt.size,State2#stateypt.count]),
    {noreply, State2};
    
%% handle_info({Size, Count}, State) ->
%%     
%%     State2 = #stateypt{size = State#stateypt.size + Size,count = State#stateypt.count + Count},
%%     io:format(" size  = ~p~n count = ~p~n~n~n",[State2#stateypt.size,State2#stateypt.count]),
%%     
%%     case State2#stateypt.size > ?MAX_SIZE of
%%       true -> 
%%         case lists:member(State#stateypt.size, ["0",0]) of
%%           true ->
%%             put(threeLimitypt,"1");
%%           false ->
%%              put(threeLimitypt,"0")
%%         end,
%%           io:format(" 超出最大size，清空状态，重新开启定时任务 ...... ~n"),
%%           %% ergmbs_yptConvert:yptConvert(),
%%           clean_timer(State#stateypt.timed_task),
%%           State3 = #stateypt{};
%%       _ ->
%%         case  State2#stateypt.count > ?MAX_COUNT of
%%           true ->
%%             case lists:member(State#stateypt.count, ["0",0]) of
%%               true ->
%%                 put(threeLimitypt,"1");
%%               false ->
%%                 put(threeLimitypt,"0")
%%             end,
%%             io:format(" 超出最大count，清空状态，重新开启定时任务 ...... ~n"),
%%             %% ergmbs_yptConvert:yptConvert(),
%%             clean_timer(State#stateypt.timed_task),
%%             State3 = #stateypt{};
%%           _ ->
%%             put(threeLimitypt,"1"),
%%             State3 = State2
%%         end
%%     end,
%%     {noreply, State3};
    
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
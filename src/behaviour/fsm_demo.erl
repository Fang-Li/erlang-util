-module(fsm_demo).
-compile(export_all).

-behaviour(gen_fsm).

-record(state,{state}).

start_link()->
  gen_fsm:start_link({local,?MODULE},?MODULE,[],[]).
  
init([]) ->
  io:format("init ...~n"),
  State=#state{state=static},
  io:format("init state : ~p~n",[State]),
  {ok,static,State}.
  
hero_join()->
  gen_fsm:send_event(?MODULE,hero_join).
  
hero_leave()->
  gen_fsm:send_event(?MODULE,hero_leave).
  
%% 静止状态下接受事件
static(Event,State)->
  case Event of
    hero_join ->
     do_moving(),
     NewState = State#state{state=moving},
     io:format("set state : ~p~n",[NewState]),
     {next_state,moving,NewState}
  end.
  
%% 移动状态下接受事件
moving(Event,State)->
  case Event of 
    hero_leave ->
      do_static(),
      NewState = State#state{state=static},
      io:format("set state : ~p~n",[NewState]),
      {next_state,static,NewState}
  end.
  
handle_event(Event,StateName,State)->
  io:format("handle event .. ~p,~p,~p~n",[Event,StateName,State]),
  {next_state,StateName,State}.
  
handle_sync_event(Event,From,StateName,State)->
  io:format("handle sync .. ~p,~p,~p,~p~n",[Event,From,StateName,State]),
  {reply,okk,StateName,State}.
  
handle_info(Info,StateName,State)->
  io:format("handle info .. ~p,~p,~p~n",[Info,StateName,State]),
  {next_state,StateName,State}.
  
terminate(Reason,StateName,State) ->
  io:format("terminate .. ~p,~p,~p~n",[Reason,StateName,State]),
  ok.
  
code_change(OldVsn,StateName,State,Extra)->
  {ok,StateName,State}.
  
do_moving()->
  io:format("begin moving .. ~n").
do_static()->
  io:format("stop moving, join static ..~n").
  
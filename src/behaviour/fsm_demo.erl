-module(fsm_demo).
-compile(export_all).

-behaviour(gen_fsm).

-record(state, {state}).

%%gen_fsm moduleCallbackmodule
%%-----------------------------
%%gen_fsm:start_link ----->Module:init/1
%%gen_fsm:send_event ----->Module:StateName/2
%%gen_fsm:send_all_state_event ----->Module:handle_event/3
%%gen_fsm:sync_send_event ----->Module:StateName/3
%%gen_fsm:sync_send_all_state_event ----->Module:handle_sync_event/4
%%------>Module:handle_info/3
%%------>Module:terminate/3
%%------>Module:code_change/4


start_link() ->
    gen_fsm:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    io:format("init ...~n"),
    State = #state{state = static},
    io:format("init state : ~p~n", [State]),
    {ok, static, State}.

hero_join() ->
    gen_fsm:send_event(?MODULE, hero_join).

hero_leave() ->
    gen_fsm:send_event(?MODULE, hero_leave).

%% 静止状态下接受事件
static(Event, State) ->
    case Event of
        hero_join ->
            do_moving(),
            NewState = State#state{state = moving},
            io:format("set state : ~p~n", [NewState]),
            {next_state, moving, NewState}
    end.

%% 最后一行和发什么reply都会向From发送消息, From只取第一个返回当做函数返回值
static(Event, From, State) ->
    io:format("from ~p~n", [From]),
    case Event of
        hero_join ->
            do_moving(),
            NewState = State#state{state = moving},
            io:format("set state : ~p~n", [NewState]),
            {reply, okk1, static, State};
        a ->
            gen_fsm:reply(From, okk3),
            io:format("after reply~n"),
            gen_fsm:reply(From, okk5),
            {reply, okk6, static, State};
        b ->
            gen_fsm:reply(From, okk3),
            {next_state, moving, State};
        D ->
            {reply, D, static, State}
    end.

%% 移动状态下接受事件
moving(Event, State) ->
    case Event of
        hero_leave ->
            do_static(),
            NewState = State#state{state = static},
            io:format("set state : ~p~n", [NewState]),
            {next_state, static, NewState}
    end.

handle_event(Event, StateName, State) ->
    io:format("handle event .. ~p,~p,~p~n", [Event, StateName, State]),
    {next_state, StateName, State}.

handle_sync_event(Event, From, StateName, State) ->
    io:format("handle sync .. ~p,~p,~p,~p~n", [Event, From, StateName, State]),
    {reply, okk, StateName, State}.

handle_info(Info, StateName, State) ->
    io:format("handle info .. ~p,~p,~p~n", [Info, StateName, State]),
    {next_state, StateName, State}.

terminate(Reason, StateName, State) ->
    io:format("terminate .. ~p,~p,~p~n", [Reason, StateName, State]),
    ok.

code_change(OldVsn, StateName, State, Extra) ->
    {ok, StateName, State}.

do_moving() ->
    io:format("begin moving .. ~n").
do_static() ->
    io:format("stop moving, join static ..~n").
  
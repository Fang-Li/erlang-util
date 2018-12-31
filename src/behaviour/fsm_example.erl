-module(fsm_example).
-behaviour(gen_fsm).
-compile(export_all).
-define(L(K,V),io:format("~n~p  -------------------  ~p~n~n",[K,V])).
%% interface routines

%% start us up
start() -> gen_fsm:start({local, hello}, fsm_example, [], []).

%% send a hello -- this will end up in the FSM routines
hello() -> gen_fsm:send_event(hello, {hello, self()}).

%% send a stop this will end up in "handle_event"
stop()  -> gen_fsm:send_all_state_event(hello, stopit).

%% -- interface end

%% This initialisation routine gets called
init(Args) ->
    ?L(args,Args),
    {ok, idle, []}.

%% The state machine
idle({hello, A}, []) ->
    ?L("idle .. a",A),
    {next_state, one, A}.

one({hello, B}, A) ->
    ?L("one .. A",A),
    ?L("one .. B",B),
    A ! {hello, B},
    B ! {hello, A},
    {next_state, idle, []}.

%% this handles events in *any* state
handle_event(stopit, AnyState, TheStateData) ->
    ?L("handle_event .. AnyState",AnyState),
    ?L("handle_event .. TheStateData",TheStateData),
    
    {stop, i_shall_stop, []}.   %% tell it to stop


%% This is the finalisation routine - it gets called
%% When we have to stop
terminate(i_shall_stop, TheStateIwasIn, TheStateData) ->
    ?L("terminate .. TheStateIwasIn",TheStateIwasIn),
    ?L("terminate .. TheStateData",TheStateData),
    
    ok.
    
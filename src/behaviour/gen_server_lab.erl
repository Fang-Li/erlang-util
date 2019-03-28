%%%-------------------------------------------------------------------
%%% @author lifang
%%% @copyright (C) 2019, <Wish Start>
%%% @doc
%%%
%%% @end
%%% Created : 20. Mar 2019 5:16 PM
%%%-------------------------------------------------------------------
-module(gen_server_lab).
-author("lifang").

-behaviour(gen_server).

%% API
-export([start_link/0, start_link2/0]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).



start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


start_link2() ->
    Pid = proc_lib:spawn_link(?MODULE, init, [[2]]),
    {ok, Pid}.


init([2]) ->
    io:format("async init~n"),
    timer:sleep(1000),
    io:format("async init done~n"),
    gen_server:enter_loop(?MODULE, [], #state{});


init([]) ->
    io:format("init .. ~p~n", [self()]),
    self() ! continue_init,
    io:format("init2 .. ~p~n", [self()]),
    {ok, #state{}}.


-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
  State :: #state{}) ->
    {reply, Reply :: term(), NewState :: #state{}} |
    {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

-spec(handle_cast(Request :: term(), State :: #state{}) ->
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
    {noreply, State}.


-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_info(continue_init, State) ->
    io:format("info .. ~p~n", [self()]),
    {noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.


-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
  State :: #state{}) -> term()).
terminate(_Reason, _State) ->
    ok.

-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
  Extra :: term()) ->
    {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%%-------------------------------------------------------------------
% gen_server自动调用最新的code beam
% 都不用reload
% 那么reloader的作用就是强制当下使用最新的code beam
%%%-------------------------------------------------------------------
-module(hot_reload_v3).
-author("lifang").

-behaviour(gen_server).

%% API
-export([start_link/1,
    echo/1]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).
-time(aaa).

-record(state, {}).

start_link(ClientPid) ->
    register(client, ClientPid),
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.


handle_info(timeout = Info, State) ->
    Info2 = echo(Info),
    send_to_client(Info2),
    {noreply, State, 2000};

handle_info(Info, State) ->
    Info2 = echo(Info),
    send_to_client(Info2),
    {noreply, State}.

terminate(Reason, _State) ->
    send_to_client(Reason),
    unregister(client),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

send_to_client(Message) ->
    send_to(client, Message).

send_to(Client, Message) ->
    Client ! io:format("reply : ~p ~n", [Message]).


echo(Item) ->
    case Item of
        tea -> 2.05;
        coffee -> 2.10;
        milk -> 0.99;
        bread -> 0.50;
        timeout -> 2;
        _ -> Item
    end.


% c(hot_reload_v3).
% {ok,Service} = hot_reload_v3:start_link(self()).
% Service ! milk.

% code:purge(hot_reload_v3).
% code:soft_purge(hot_reload_v3).
% code:load_file(hot_reload_v3).

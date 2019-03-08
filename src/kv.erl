-module(kv).
%% These define the client API
-export([start/0, store/2, lookup/1]).
%% these must be defined because they are called by gs
-export([init/1, handle_call/3]).
-compile(export_all).
-define(GS, mini_gs).
%% -define(GS, gen_server).
%% define the client API
start() -> ?GS:start_link({local, someatom}, kv, foo, []).
store(Key, Val) -> ?GS:call(someatom, {putval, Key, Val}).
lookup(Key) -> ?GS:call(someatom, {getval, Key}).
%% define the internal routines
init(foo) -> {ok, dict:new()}.
handle_call({putval, Key, Val}, _From, Dict) ->
  {reply, ok, dict:store(Key, Val, Dict)};
handle_call({getval, Key}, _From, Dict) ->
  {reply, dict:find(Key, Dict), Dict}.
 
%


dict(Key, Value) ->
  catch ets:new(kv, [duplicate_bag, public, named_table]),
  ets:insert(kv, {Key, Value}),
  ets:insert(kv, {Value, Key}).

-module(ets_labs).
-export([match_vs_select/2, loop/2]).

-record(player_item, {id, xd, player_id, item_id, grid}).

%%
%% Match和Select性能对比
%%
match_vs_select (PlayerNum, RowsPerPlayer) ->
  Tab = ets:new(player_item, [{keypos, #player_item.id}]),
  init_test_data(PlayerNum, RowsPerPlayer, Tab, 1),
  %% 主键select
  R1 = timer:tc(?MODULE, loop, [100, fun() ->
    ets:select(Tab, [{#player_item { 
      id = PlayerNum * RowsPerPlayer div 2, _='_' 
    },[],['$_']}])
  end]),
  io:format("select by key : ~p~n", [R1]),
  %% 主键match
  R2 = timer:tc(?MODULE, loop, [100, fun() -> 
    ets:match_object(Tab, #player_item { 
      id = PlayerNum * RowsPerPlayer div 2, _='_' 
    }) 
  end]),
  io:format("match by key  : ~p~n", [R2]),
  %% 非主键select
  R3 = timer:tc(?MODULE, loop, [100, fun() ->
    ets:select(Tab, [{#player_item { 
      xd = PlayerNum * RowsPerPlayer div 2, _='_' 
    },[],['$_']}])
  end]),
  io:format("select all    : ~p~n", [R3]),
  %% 非主键match
  R4 = timer:tc(?MODULE, loop, [100, fun() -> 
    ets:match_object(Tab, #player_item { 
      xd = PlayerNum * RowsPerPlayer div 2, _='_' 
    }) 
  end]),
  io:format("match all     : ~p~n", [R4]),
  %% 主键lookup
  R5 = timer:tc(?MODULE, loop, [100, fun() -> 
    ets:lookup(Tab, PlayerNum * RowsPerPlayer div 2) 
  end]),
  io:format("lookup        : ~p~n", [R5]),
  ets:delete(Tab).

loop (0, _) ->
  ok;
loop (Times, Fun) ->
  Fun(),
  loop(Times - 1, Fun).

%%
%% 初始化测试数据
%%
init_test_data (0, _, _, _) ->
  ok;
init_test_data (PlayerNum, RowsPerPlayer, Tab, Id) ->
  Id2 = init_player_data(RowsPerPlayer, Tab, Id, PlayerNum),
  init_test_data(PlayerNum - 1, RowsPerPlayer, Tab, Id2).
  
init_player_data (0, _, Id, _) ->
  Id;
init_player_data (Rows, Tab, Id, PlayerId) ->
  true = ets:insert(Tab, #player_item { 
    id = Id, xd = Id, player_id = PlayerId, item_id = Rows, grid = Rows
  }),
  init_player_data(Rows - 1, Tab, Id + 1, PlayerId).
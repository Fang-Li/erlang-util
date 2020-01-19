-module(ets_msg).
-compile(export_all).
-define(MAX, 5).

test() ->
  ets:new(msg,[named_table,set,public]),
  ets:new(msg_bag,[named_table,bag,public]),
  ets:new(msg_duplicate_bag,[named_table,duplicate_bag,public]),
  ets:insert(msg,{u1,[{1 ,x1 ,y1},{3 ,x3 ,y3},{5 ,x5 ,y5}, {7 ,x7 ,y7 },  {9 ,x9 ,y9 }]}),
  ets:insert(msg,{u2,[{ 2,x2 ,y2},{4 ,x4 ,y4},{6 ,x6 ,y6},{8 ,x8 ,y8 },{10 ,x10 ,y10 }]}),
  ok.
  
  
get(User, Ver) ->
  %% 读取Msg
  Msg = ets:lookup(msg,User),
  case Msg of
    [] ->
      [];
    _  ->
      MsgList = proplists:get_value(User,Msg),
      %% 大于当前版本号的消息
      _NewMsgList = lists:filter(fun({V,X,Y}) -> V > Ver  end,MsgList)
  end.
  
  
pop(User, Ver) ->
  %% 读取Msg
  Msg = ets:lookup(msg,User),
  case Msg of
    [] -> [];
    _  ->  
      MsgList = proplists:get_value(User,Msg),
  
      %% 大于当前版本号的消息
      NewMsgList = lists:filter(fun({V,X,Y}) -> V > Ver  end,MsgList),
  
      %% 保留当前部分消息
      % ets:delete(msg,User),
      ets:insert(msg,{User,NewMsgList}),
      
      %% 返回满足当前版本的消息
      NewMsgList
  end.
  

push(User,Msg) ->
    Msg2 = ets:lookup(msg,User),
    case Msg2 of
      [] -> [];
      _  ->  
        MsgList = proplists:get_value(User,Msg2),
        case erlang:length(MsgList) < ?MAX of
          true ->
            NewMsgList = [MsgList | Msg];
          _ ->
            [_H | T] = MsgList,
            NewMsgList = T ++ [Msg]
        end,
        ets:insert(msg,{User, NewMsgList})
    end.

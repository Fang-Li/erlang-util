-module(ets_match).
-compile(export_all).
% -record(msg,{ver,x,y}).

-include_lib("stdlib/include/ms_transform.hrl"). %% match specifications


test() ->
  ets:new(msg_ver_bag, [duplicate_bag, public, named_table]),
  
  ets:insert(msg_ver_bag,{u1,{1,a1,b1}}),
  ets:insert(msg_ver_bag,{u1,{2,a2,b2}}),
  ets:insert(msg_ver_bag,{u1,{3,a3,b3}}),
  ets:insert(msg_ver_bag,{u2,{4,a4,b4}}),
  ets:insert(msg_ver_bag,{u2,{5,a5,b5}}),
  ets:insert(msg_ver_bag,{u2,{6,a6,b6}}),
  ets:insert(msg_ver_bag,{u2,{7,a7,b7}}),
  
  ets:new(msg, [duplicate_bag, public, named_table]),
  ets:insert(msg,{msg,1,a1,b1}),
  ets:insert(msg,{msg,2,a2,b2}),
  ets:insert(msg,{msg,3,a3,b3}),
  ets:insert(msg,{msg,4,a4,b4}),
  ets:insert(msg,{msg,5,a5,b5}),
  ets:insert(msg,{msg,6,a6,b6}),
  ets:insert(msg,{msg,7,a7,b7}).
  % MS = ets:fun2ms(fun(Msg2 = {M,V, X, Y}) when V > 3 -> Msg2 end).
  % ets:select(msg,MS).
  % ets:tab2list(msg).
  % f(MS),MS=ets:fun2ms(fun(Msg={M,V,X,Y}) when V > 3 -> true end).
  % ets:select_delete(msg,MS).
  % ets:tab2list(msg).         





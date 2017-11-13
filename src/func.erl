-module(func).
-compile(export_all).
-on_load({init,0}).

func_in_which_module(Func) ->
  [M || {M,_Dir} <- code:all_loaded(),{F,_Num} <- M:module_info(exports) , F == Func].
% [F == is_binary || {F,_Num} <- M:module_info(exports), M <- erlang:loaded()]
% [F == is_binary || M <- erlang:loaded(),{F,_Num} <- M:module_info(exports)]
% [M || M <- erlang:loaded(),{F,_Num} <- M:module_info(exports) , F == is_binary]
% [M || {M,_Dir} <- code:all_loaded(),{F,_Num} <- M:module_info(exports) , F == is_binary]



init() ->
  io:format("init .. ~n",[]).

test()->
  ok.





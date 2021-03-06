-module(func).
-compile(export_all).
-on_load({init, 0}).

-record(a, {b, c}).

func_in_which_module(Func) ->
    [M || {M, _Dir} <- code:all_loaded(), {F, _Num} <- M:module_info(exports), F == Func].
% [F == is_binary || {F,_Num} <- M:module_info(exports), M <- erlang:loaded()]
% [F == is_binary || M <- erlang:loaded(),{F,_Num} <- M:module_info(exports)]
% [M || M <- erlang:loaded(),{F,_Num} <- M:module_info(exports) , F == is_binary]
% [M || {M,_Dir} <- code:all_loaded(),{F,_Num} <- M:module_info(exports) , F == is_binary]



init() ->
    application_controller:set_env(_App = stdlib, _Name = shell_catch_exception, true),
    io:format("init .. ~n", []).

test() ->
    ok.



test_record() ->
    test_record(#a{b = 1, c = 2}).
test_record(#a{}) ->
    a;
test_record(_) ->
    b.


-module(fun_lab).
-compile(export_all).

fun_lab(Num) ->
    Fun = fun(0) -> a;
        (_Num) -> b
          end,
    Fun(Num).

lab(A, [A]) ->
    A;
lab(A, B) ->
    bbb.

lab2(A, B, B = C) ->
    C;
lab2(A, B, C) ->
    aaa.


lab3() ->
    F = fun(X) -> fun lab/2(a, b) end,
    F(1).

guard([A1, A1 | A]) ->
    a;
guard([A1, A2 | A]) when A1 == A2 ->
    b;
guard(_) ->
    c.

-record(a, {b = #{}}).
map(#a{b = #{}}) ->
    a;
map(_) ->
    b.



expire([[_Command, <<"uid#", _/binary>> = Key | _] | TailCMDs], [{ok, Length} | TailRets], ExpireCMDs) ->
    uid;
expire([_ | TailCMDs], [_ | TailRets], ExpireCMDs) ->
    nothing.

%% 字符串是否可以匹配
% https://api.weixin.qq.com
req() ->
    URL = "https://api.weixin.qq.com",
    req(URL).
req([$h, $t | _T] = URL) ->
    URL;
req(_URL) ->
    not_match.


%% 函数所在模块
%% 缺陷: 只能查找已经加载到内存的模块
which_mod(Func) ->
    %Loaded = [Mod || {Mod, _Path} <- code:all_loaded()],
    Loaded = all_ebin(),
    F = fun(Mod) -> Funs = [Fun || {Fun, _Arg} <- Mod:module_info(exports)], lists:member(Func, Funs) end,
    [Mod || Mod <- Loaded, F(Mod) == true].


%% 所有模块1:erlang库
all_ebin() ->
    lists:foldl(
        fun(Path, Acc) ->
            {ok, Files} = file:list_dir(Path),
            Acc3 = lists:foldl(
                fun(FileName, Acc2) ->
                    case string:tokens(FileName, ".") of
                        [Mod, "beam"] ->
                            [list_to_atom(Mod) | Acc2];
                        _ ->
                            Acc2
                    end
                end, [], Files),
            Acc3 ++ Acc
        end, [], code:get_path()).





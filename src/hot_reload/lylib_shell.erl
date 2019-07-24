%%%-------------------------------------------------------------------
%%% @author lifang
%%% @copyright (C) 2019, <Wish Start>
%%% @doc
%%%
%%% @end
%%% Created : 28. Jun 2019 7:01 PM
%%%-------------------------------------------------------------------
-module(lylib_shell).
-compile(export_all).


%% Common API
recon(MFAs, Options) ->
    recon(MFAs, [], Options).

%% 尾递归结束
recon([], [], _Options) ->
    nothing;
recon([], Acc, Options) ->
    trace(Acc, Options);

%% 三参
recon([{Mod, Func, Args} | Tail], Acc, Options) when is_atom(Mod) andalso is_atom(Func) ->
    recon(Tail, [{Mod, Func, Args} | Acc], Options);

recon([{Mods, Func, Args} | Tail], Acc, Options) when is_list(Mods) andalso is_atom(Func) ->
    Patterns = [{Mod, Func, Args} || Mod <- Mods],
    recon(Tail, Patterns ++ Acc, Options);

recon([{Mod, Funcs, Args} | Tail], Acc, Options) when is_atom(Mod) andalso is_list(Funcs) ->
    Patterns = [{Mod, Func, Args} || Func <- Funcs],
    recon(Tail, Patterns ++ Acc, Options);

recon([{Mods, Funcs, Args} | Tail], Acc, Options) when is_list(Mods) andalso is_list(Funcs) ->
    Patterns = [{Mod, Func, Args} || Mod <- Mods, Func <- Funcs],
    recon(Tail, Patterns ++ Acc, Options);

%% 二参
recon([{Mod, Func} | Tails], Acc, Options) ->
    Args = get_pattern_args(Options),
    recon([{Mod, Func, Args} | Tails], Acc, Options);

%% 一参
recon([Mod | Tail], Acc, Options) when is_atom(Mod) ->
    Args = get_pattern_args(Options),
    recon([{Mod, '_', Args} | Tail], Acc, Options);

recon([{Mod} | Tail], Acc, Options) ->
    Args = get_pattern_args(Options),
    recon([{Mod, '_', Args} | Tail], Acc, Options).


%% 默认跟踪函数的返回值
get_pattern_args(Options) ->
    case lists:keyfind(return, 1, Options) of
        {return, false} ->
            [{'_', [], [false]}];
        _ ->
            [{'_', [], [{return_trace}]}]
    end.

%% 默认跟踪2000次,包含本地未导出的函数
trace(Patterns, Options) ->
    Times2 =
        case lists:keyfind(times, 1, Options) of
            {times, Times} ->
                Times;
            _ ->
                2000
        end,
    Scope =
        case lists:keyfind(scope, 1, Options) of
            {scope, export} ->
                [];
            _ ->
                [{scope, local}]
        end,
    recon_trace:calls(Patterns, Times2, Scope).

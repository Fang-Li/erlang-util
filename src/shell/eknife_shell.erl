%%%-------------------------------------------------------------------
%%% @author lifang
%%% @copyright (C) 2019, <Wish Start>
%%% @doc
%%% 工具库命令行快捷命令
%%% @end
%%% Created : 26. Apr 2019 9:28 AM
%%%-------------------------------------------------------------------
-module(eknife_shell).
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
    recon(Tail, [{Mod, Func, args(Args, Options)} | Acc], Options);

recon([{Mods, Func, Args} | Tail], Acc, Options) when is_list(Mods) andalso is_atom(Func) ->
    Patterns = [{Mod, Func, args(Args, Options)} || Mod <- Mods],
    recon(Tail, Patterns ++ Acc, Options);

recon([{Mod, Funcs, Args} | Tail], Acc, Options) when is_atom(Mod) andalso is_list(Funcs) ->
    Patterns = [{Mod, Func, args(Args, Options)} || Func <- Funcs],
    recon(Tail, Patterns ++ Acc, Options);

recon([{Mods, Funcs, Args} | Tail], Acc, Options) when is_list(Mods) andalso is_list(Funcs) ->
    Patterns = [{Mod, Func, args(Args, Options)} || Mod <- Mods, Func <- Funcs],
    recon(Tail, Patterns ++ Acc, Options);

%% 二参
recon([{Mod, Func} | Tails], Acc, Options) ->
    Args = get_if_return(Options),
    recon([{Mod, Func, Args} | Tails], Acc, Options);

%% 一参
recon([Mod | Tail], Acc, Options) when is_atom(Mod) ->
    Args = get_if_return(Options),
    recon([{Mod, '_', Args} | Tail], Acc, Options);

recon([{Mod} | Tail], Acc, Options) ->
    Args = get_if_return(Options),
    recon([{Mod, '_', Args} | Tail], Acc, Options);

%% 匹配"a:b"格式的字符串, 解析为{M,F}
recon([ModFunc | Tail], Acc, Options) when is_list(ModFunc) ->
    {Mod, Func} = string2mf(ModFunc),
    recon([{Mod, Func} | Tail], Acc, Options);

%% 匹配"a:b"格式的字符串, 解析为{M,F}
recon(ModFunc, Acc, Options) when is_list(ModFunc) ->
    {Mod, Func} = string2mf(ModFunc),
    recon([{Mod, Func}], Acc, Options).

string2mf(ModFunc) ->
    case string:tokens(ModFunc, ":") of
        [Mod, Func] when Mod /= [] andalso Func /= [] ->
            {type_util:to_atom(Mod), type_util:to_atom(Func)};
        _ ->
            throw(ModFunc)
    end.
%%---------------------------- args支持多种格式 ----------------------------------------

%% 指定参数个数
args(Args, Options) when is_integer(Args) ->
    case is_trace_return(Options) of
        true ->
            [{'$1', [{'==', {length, '$1'}, Args}], [{return_trace}]}];
        false ->
            [{'$1', [{'==', {length, '$1'}, Args}], [a]}]
    end;

%% 已经是fun函数生成的模式匹配,无需处理
args(Args, _Options) ->
    Args.


%% 默认跟踪函数的返回值
get_if_return(Options) ->
    case is_trace_return(Options) of
        false ->
            [{'_', [], [false]}];
        true ->
            [{'_', [], [{return_trace}]}]
    end.

%% 是否跟踪函数的返回值
is_trace_return(Options) ->
    case lists:keyfind(return, 1, Options) of
        {return, false} ->
            false;
        _ ->
            true
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

%%---------------------------- 特定 API----------------------------------------

%% dbg:tpl( mnesia_meter, dbg:fun2ms(fun(_) -> return_trace() end)).
%% dbg:fun2ms(fun(_) -> return_trace() end)

%% dbg:fun2ms(fun([Msg,bifrost_request]) when Msg =/= <<74,2,18,0>> -> return_trace() end).
%% dbg:fun2ms(fun([Args,bifrost_response]) -> false end).

%% 跟踪所有protobuf接口数据
recon() ->
    RequestMFA = bifrost_request(),
    ResponseMFA = {bifrost_response, encode_msg, [{['$1', bifrost_response], [], [false]}]},
    recon([RequestMFA, ResponseMFA], []).

%% 跟踪ocean、nuwa、poseidon protobuf接口数据
trace_without_ping() ->
    RequestMFA = bifrost_request(),
    ResponseMFA = bifrost_response([nuwa, ocean, poseidon]),
    recon([RequestMFA, ResponseMFA], []).

%% 跟踪指定ocean、club、nuwa等protobuf接口数据
trace_specified_server(Server) when is_atom(Server) ->
    trace_specified_server([Server]);

trace_specified_server(Servers) when is_list(Servers) ->
    RequestMFA = bifrost_request(),
    ResponseMFA = bifrost_response(Servers),
    recon([RequestMFA, ResponseMFA], []).

bifrost_request() ->
    Args = [
        {
            ['$1', bifrost_request],
            [{'=/=', '$1', <<74, 2, 18, 0>>}],
            [{return_trace}]
        }],
    {bifrost_request, decode_msg, Args}.

bifrost_response(Servers) ->
    Args = lists:foldl(
        fun(Server, Acc) ->
            [{[#{Server => '_'}, bifrost_response], [], [false]} | Acc]
        end, [], Servers),
    {bifrost_response, encode_msg, Args}.

purge(Mod) ->
    code:purge(Mod),
    code:load_file(Mod).

soft_purge(Mod) ->
    code:soft_purge(Mod),
    code:load_file(Mod).
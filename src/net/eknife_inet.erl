%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% 
%%% @end
%%%-------------------------------------------------------------------
-module(eknife_inet).

-compile(export_all).

getAddr() ->
    Fin =
        case inet:getif() of
            {ok, Ips} when is_list(Ips) ->
                get_rel_addr(Ips);
            _ ->
                <<"127.0.0.1">>
        end,
    type_util:to_list(Fin).

get_rel_addr([]) ->
    <<"127.0.0.1">>;
get_rel_addr([{{172, _B, _C, _D} = FinIP, _BroadCast, _Mask} | _Ips]) ->
    type_util:ip_to_list(FinIP);
get_rel_addr([_IP | Ips]) ->
    get_rel_addr(Ips).

%% 获取网络地址IP: 忽略docker和网桥等虚拟网卡
withsocket(Fun) ->
    case inet_udp:open(0, []) of
        {ok, Socket} ->
            Res = Fun(Socket),
            inet_udp:close(Socket),
            Res;
        Error ->
            Error
    end.

getif() ->
    withsocket(fun(S) -> getif(S) end).

getif(Socket) ->
    case getiflist(Socket) of
        {ok, IfList} ->
            {ok, lists:foldl(
                fun(Name, Acc) ->
                    case prim_inet:ifget(Socket, Name,
                        [addr, broadaddr, netmask]) of
                        {ok, [{addr, A}, {broadaddr, B}, {netmask, M}]} ->
                            [{A, B, M} | Acc];
                        %% Some interfaces does not have a b-addr
                        {ok, [{addr, A}, {netmask, M}]} ->
                            [{A, undefined, M} | Acc];
                        _ ->
                            Acc
                    end
                end, [], IfList)};
        Error -> Error
    end.


getiflist(Socket) ->
    case prim_inet:getiflist(Socket) of
        {ok, IfList} ->
            IfList2 = lists:filter(
                fun
                    ("br-" ++ _Bridge) ->
                        false;
                    ("docker" ++ _Docker) ->
                        false;
                    (_) ->
                        true
                end, IfList),
            if IfList2 == [] -> {error, empty}; true -> {ok, IfList2} end;
        _ ->
            {error, empty}
    end.

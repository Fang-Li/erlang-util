%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% 加权轮询调度
%%% @end
%%%-------------------------------------------------------------------
-module(wrr).
-compile(export_all).
-define(Tab, ?MODULE).
-define(Server, ?MODULE).
-record(node, {addr, weight = 0, cw = 0}).


start() ->
    gen_server:start({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    init2(),
    {ok, []}.

%% 查询节点调用次数
handle_call({times, Node}, _, _) ->
    {reply, [get(Node)], []};

handle_call(get, _, _) ->
    {reply, ets:tab2list(?Tab), []};

handle_call(_, _, _) ->
    {reply, [], []}.

%% 更新节点current_weight
handle_cast({insert, Nodes}, _) ->
    insert(Nodes),
    {noreply, []};

%% 统计节点调用次数
handle_cast({incr, Node}, _) ->
    incr(Node),
    {noreply, []};

handle_cast(_, _) ->
    {noreply, []}.

handle_info(_, _) ->
    {noreply, []}.

terminate(_, _) ->
    ok.

code_change(_, _, _) ->
    {ok, []}.

%% 初始化节点权重表
init() ->
    ets:new(?Tab, [set, public, named_table, {keypos, #node.addr}, {read_concurrency, true}, {write_concurrency, true}]),
    ets:insert(?Tab,
        [
            #node{addr = a, weight = 3},
            #node{addr = b, weight = 2},
            #node{addr = c, weight = 1}
        ]).

%% 初始化节点权重表
init2() ->
    ets:new(?Tab, [set, public, named_table, {keypos, #node.addr}, {read_concurrency, true}, {write_concurrency, true}]),
    ets:insert(?Tab,
        [
            #node{addr = a, weight = 3},
            #node{addr = b, weight = 3},
            #node{addr = c, weight = 3},
            #node{addr = d, weight = 1}
        ]).

init3() ->
    ets:new(?Tab, [set, public, named_table, {keypos, #node.addr}, {read_concurrency, true}, {write_concurrency, true}]),
    ets:insert(?Tab,
        [
            #node{addr = a, weight = 5},
            #node{addr = b, weight = 1},
            #node{addr = c, weight = 1}
        ]).

%% 取出负载节点
wrr() ->
    Nodes = gen_server:call(?Server, get),
    lb(Nodes).

%% 取出负载节点
lb(Nodes) ->
    if
        length(Nodes) == 0 -> [];
        true ->
            Best = do_lb(Nodes),
            %% 次数统计
            gen_server:cast(?MODULE, {incr, Best#node.addr}),
            Best
    end.

do_lb(Nodes) ->
    {Best3, Others3, Sum3} =
        lists:foldl(
            fun(Node, {Best, Others, Sum}) ->
                Temp = Node#node{cw = Node#node.cw + Node#node.weight},
                Sum2 = Sum + Node#node.weight,

                {Best2, Others2} =
                    if
                        Best == nil ->
                            {Temp, Others};
                        Temp#node.cw > Best#node.cw ->
                            {Temp, [Best | Others]};
                        true ->
                            {Best, [Temp | Others]}
                    end,
                {Best2, Others2, Sum2}
            end, {nil, [], 0}, Nodes),

    Best4 = Best3#node{cw = Best3#node.cw - Sum3},
    %% 更新所有节点
    gen_server:cast(?MODULE, {insert, [Best4 | Others3]}),
    Best4.

%% 更新所有节点
insert(Nodes) ->
    ets:insert(?Tab, Nodes).

%% 动态调整
inesrt(A, W, C) ->
    ets:insert(?Tab, #node{addr = A, weight = W, cw = C}).

%% 压测
test_lb(_) ->
    wrr().

test() ->
    performance_test:main(100, 100000, fun test_lb/1, [], 3).

%% 调用次数统计
incr(Node) ->
    case get(Node) of
        undefined -> put(Node, 1);
        Times ->
            put(Node, Times + 1)
    end.

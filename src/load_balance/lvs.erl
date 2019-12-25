%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% 加权轮询调度:最大公约数
%%% @end
%%%-------------------------------------------------------------------
-module(lvs).
-compile(export_all).
-define(Tab, ?MODULE).
-define(Max, max).
-define(Server, ?MODULE).
-record(node, {addr, weight = 0, index = -1, cw = 0}).
-record(max, {index = -1, w = 0}).

start() ->
    gen_server:start({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    init(),
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
handle_cast({insert_max, Max}, _) ->
    insert_max(Max),
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
    ets:new(?Max, [set, public, named_table, {read_concurrency, true}, {write_concurrency, true}]),
    ets:insert(?Tab,
        [
            #node{addr = a, index = 1, weight = 3},
            #node{addr = b, index = 2, weight = 2},
            #node{addr = c, index = 3, weight = 1}
        ]),
    ets:insert(?Max, #max{}).

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
            [Max] = ets:lookup(?Max, ?Max),
            Best = do_lb(Nodes, Max),
            gen_server:cast(?Server, {insert_max, #max{index = Best#node.index, w = Best#node.weight}}),
            gen_server:cast(?Server, {insert, Best}),
            %% 次数统计
            gen_server:cast(?Server, {incr, Best#node.addr}),
            Best
    end.



do_lb(Nodes, Max) ->
    Len = length(Nodes),
    do_lb(Nodes, Max, Len).

do_lb(Nodes, #max{index = MaxIndex, w = MaxW} = Max, Len) ->
    MaxIndex2 = (MaxIndex + 1) rem Len,
    MaxW3 =
        if
            MaxIndex2 == 0 ->
                MaxW2 = MaxW - gcd(Nodes),
                if
                    MaxW2 == 0 -> max(Nodes);
                    true -> MaxW2
                end;
            true ->
                MaxW
        end,
    do_lb2(Nodes, Max#max{index = MaxIndex2, w = MaxW3}, {}).

do_lb2([], _, {}) ->
    nil;

do_lb2([], _, continue) ->
    nil;

do_lb2(_, _, {return, Node}) ->
    Node;

do_lb2([Node | Tail], Max, _) ->
    Ret =
        if
            Node#node.weight >= Max#max.w ->
                {return, Node};
            true ->
                continue
        end,
    do_lb2(Tail, Max, Ret).


max(Nodes) ->
    lists:foldl(
        fun(#node{weight = W1}, W2) ->
            if
                W1 >= W2 -> W1;
                true -> W2
            end
        end, 0, Nodes).

gcd(Nodes) ->
    Weights = lists:foldl(
        fun(#node{weight = Weight}, Acc) ->
            if Weight == 1 orelse Weight == 0 ->
                Acc;
                true ->
                    [Weight | Acc]
            end
        end, [], Nodes),
    eknife_math:gcd(Weights).

%% 更新所有节点
insert(Nodes) ->
    ets:insert(?Tab, Nodes).

insert_max(Max) ->
    ets:insert(?Max, Max).

%% 动态调整
inesrt(A, W, C) ->
    ets:insert(?Tab, #node{addr = A, weight = W, cw = C}).

%% 压测
test_lb(_) ->
    wrr().

test() ->
    performance_test:main(100, 1000000, fun test_lb/1, [], 3).

%% 调用次数统计
incr(Node) ->
    case get(Node) of
        undefined -> put(Node, 1);
        Times ->
            put(Node, Times + 1)
    end.

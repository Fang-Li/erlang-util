%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% 加权轮询调度+池子
%%% @end
%%%-------------------------------------------------------------------
-module(pool).
-author("lifang").
-compile(export_all).
-behaviour(gen_server).
-export([start_link/0]).
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).
-record(state, {}).
-define(Stack,
    fun(Function, Args) ->
        try erlang:apply(?MODULE, Function, Args)
        catch E:R ->
            error_logger:error_msg("stack ~p ~p ~p", [E, R, erlang:get_stacktrace()]),
            error
        end
    end).



-define(POOL_SIZE(PoolName), pool_global:size(PoolName)).
-define(POOL_MANAGER_TAB, pool_manager).
-define(Tab, ?MODULE).
-define(Config_Table, config).
-define(Server, ?MODULE).
-record(node, {addr, weight = 0, curr_weight = 0}).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

test_lb(_) ->
    node_get().

test() ->
    performance_test:main(1000, 100000, fun test_lb/1, [], 3).

%% 取出负载节点
node_get() ->
    [{_, PoolSize}] = ets:lookup(?POOL_MANAGER_TAB, node),
    try
        N = ets:update_counter(?Tab, sq, {2, 1, PoolSize, 1}),
        [{N, Node}] = ets:lookup(?Tab, N),
        gen_server:cast(?SERVER, {incr, [Node#node.addr]}),
        Node
    catch
        _:Error ->
            {error, Error}
    end.


%% 初始化负载节点
sum(Nodes) ->
    lists:foldl(
        fun(#node{weight = W}, Sum) ->
            W + Sum
        end, 0, Nodes).


init_router() ->
    Nodes = ets:tab2list(?Config_Table),
    Sum = sum(Nodes),
    NodesAcc2 = lists:foldl(
        fun(Seq, NodesAcc) ->
            Node = lb(),
            [{Seq, Node} | NodesAcc]
        end, [], lists:seq(1, Sum)),
    ets:insert(?Tab, NodesAcc2).

lb() ->
    Nodes = ets:tab2list(?Config_Table),
    lb(Nodes).


lb(Nodes) ->
    if
        length(Nodes) == 0 -> [];
        true ->
            ChooseNode = do_lb(Nodes),
            ets:insert(?Config_Table, ChooseNode),
            ChooseNode
    end.

do_lb(Nodes) ->
    {ChoosedServer3, TailAcc, Total3} = lists:foldl(
        fun(Server, {ChoosedServer, Acc, Total}) ->
            Cw = Server#node.curr_weight + Server#node.weight,
            Total2 = Total + Server#node.weight,
            {ChoosedServer2, Acc2} =
                if
                    ChoosedServer == #node{} ->
                        {Server, Acc};
                    ChoosedServer#node.curr_weight < Cw ->
                        ChoosedCw = ChoosedServer#node.curr_weight + ChoosedServer#node.weight,
                        {Server, [ChoosedServer#node{curr_weight = ChoosedCw} | Acc]};
                    true ->
                        {ChoosedServer, [Server#node{curr_weight = Cw} | Acc]}
                end,
            {ChoosedServer2, Acc2, Total2}
        end, {#node{}, [], 0}, Nodes),

    ChoosedCw = ChoosedServer3#node.curr_weight,
    ChoosedW = ChoosedServer3#node.weight,
    ChoosedServer4 = ChoosedServer3#node{curr_weight = ChoosedCw + ChoosedW - Total3},

    insert([ChoosedServer4 | TailAcc]),
    ChoosedServer4.

%%---------------------------- 以下是回调函数 ----------------------------------------

init([]) ->
    init(),
    {ok, #state{}}.

handle_call({Function, Args}, _From, State) ->
    Ret = ?Stack(Function, Args),
    {reply, Ret, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({Function, Args}, State) ->
    ?Stack(Function, Args),
    {noreply, State};

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% 节点调用次数
times_get(Node) ->
    get(Node).

%% 调用次数统计
incr(Node) ->
    case get(Node) of
        undefined -> put(Node, 1);
        Times ->
            put(Node, Times + 1)
    end.

insert(Nodes) ->
    ets:insert(?Config_Table, Nodes).

%% 初始化节点权重表
init() ->
    ets:new(?Config_Table, [set, public, named_table, {keypos, #node.addr}, {read_concurrency, true}, {write_concurrency, true}]),
    ets:insert(?Config_Table,
        [
            #node{addr = a, weight = 3},
            #node{addr = b, weight = 2},
            #node{addr = c, weight = 1}
        ]),
    ets:new(?Tab, [set, public, named_table, {read_concurrency, true}, {write_concurrency, true}]),
    true = ets:insert(?Tab, [{sq, 0}]),
    ets:new(?POOL_MANAGER_TAB, [named_table, public, {read_concurrency, true}]),
    ets:insert(?POOL_MANAGER_TAB, {node, sum(ets:tab2list(?Config_Table))}),
    init_router().

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


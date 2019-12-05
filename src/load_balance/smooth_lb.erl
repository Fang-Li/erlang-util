%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% 平滑的加权轮询算法 load
%%% @end
%%%-------------------------------------------------------------------
-module(smooth_lb).
-compile(export_all).
-define(Tab, ?MODULE).
-record(node, {addr, weight = 0, curr_weight = 0}).


start() ->
    gen_server:start({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    init2(),
    {ok, []}.
handle_call({get, Args}, _, _) ->
    Nodes = ets:tab2list(?Tab),
    {reply, Nodes, []};
handle_call({insert, Args}, _, _) ->
    insert(Args),
    {reply, [], []}.

handle_cast({incr, Node}, _) ->
    incr(Node),
    {noreply, []};

handle_cast(Args, _) ->
    insert(Args),
    {noreply, []}.

handle_info(timeout, _) ->
    {noreply, []}.

terminate(_, _) ->
    ok.

code_change(_, _, _) ->
    {ok, []}.

init2() ->
    ets:new(?Tab, [set, public, named_table, {keypos, #node.addr}, {read_concurrency, true}]),
    ets:insert(?Tab,
        [
            #node{addr = a, weight = 3},
            #node{addr = b, weight = 3},
            #node{addr = c, weight = 3},
            #node{addr = d, weight = 1}
        ]).

init() ->
    ets:new(?Tab, [set, public, named_table, {keypos, #node.addr}, {read_concurrency, true}]),
    ets:insert(?Tab,
        [
            #node{addr = a, weight = 3},
            #node{addr = b, weight = 2},
            #node{addr = c, weight = 1}
        ]).

lb() ->
    Nodes = gen_server:call(?MODULE, {get, ?Tab}),
    lb(Nodes).

lb(Nodes) ->
    if
        length(Nodes) == 0 -> [];
        true ->
            ChooseNode = do_lb(Nodes),
            %ets:insert(?MODULE, ChooseNode),
            gen_server:cast(?MODULE, {incr, ChooseNode#node.addr}),
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

    gen_server:call(?MODULE, {insert, [ChoosedServer4 | TailAcc]}),
    ChoosedServer4.

insert(Nodes) ->
    ets:insert(?Tab, Nodes).

inesrt(A, W, Cw) ->
    ets:insert(?Tab, #node{addr = A, weight = W, curr_weight = Cw}).

test_lb(_) ->
    lb().

test() ->
    performance_test:main(10, 1000, fun test_lb/1, [], 1).


incr(Node) ->
    case get(Node) of
        undefined -> put(Node, 1);
        Times ->
            put(Node, Times + 1)
    end.

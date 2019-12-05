%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% 负载
%%% @end
%%%-------------------------------------------------------------------
-module(lb).

-compile(export_all).

-record(node, {addr, w = 0, cw = 0, ew = 0}).
-define(Tab, ?MODULE).

init() ->
    ets:new(?Tab, [set, public, named_table, {keypos, #node.addr}, {read_concurrency, true}, {write_concurrency, true}]),
    ets:insert(?Tab,
        [
            #node{addr = a, ew = 3},
            #node{addr = b, ew = 2},
            #node{addr = c, ew = 1}
        ]).

lb() ->
    lb(ets:tab2list(?Tab)).

lb(Nodes) ->
    if
        length(Nodes) == 0 -> [];
        true ->
            ChooseNode = do_lb(Nodes),
            ets:insert(?MODULE, ChooseNode),
            ChooseNode
    end.


do_lb(Nodes) ->
    {ChooseNode3, Total3} = lists:foldl(
        fun(Node, {ChooseNode, Total}) ->
            NodeEw = if
                         Node#node.ew == 0 -> Node#node.cw;
                         true -> Node#node.ew
                     end,
            NodeCw = Node#node.cw + NodeEw,
            Total2 = Total + NodeEw,
            ChooseNode2 = if
                              ChooseNode == #node{} orelse NodeCw > ChooseNode#node.cw ->
                                  Node#node{cw = NodeCw, ew = NodeEw};
                              true ->
                                  ChooseNode
                          end,
            {ChooseNode2, Total2}
        end, {#node{}, 0}, Nodes),
    ChooseNodeCw = ChooseNode3#node.cw - Total3,
    ChooseNode3#node{cw = ChooseNodeCw}.


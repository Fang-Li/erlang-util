%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% 
%%% @end
%%%-------------------------------------------------------------------
-module(eknife_ets).

-compile(export_all).

dequeue(Table) ->
    case ets:first(Table) of
        '$end_of_table' -> nothing;
        Key ->
            ets:delete(Table, Key)
    end.

init() ->
    init(a).
init(Tab) ->
    Tab = ets:new(Tab, [public, named_table, duplicate_bag]),
    ets:insert(Tab, [{a, 1}, {b, 2}, {a, 3}, {a, 1}, {c, 4}, {d, 5}]),
    Tab.

first_match(Tab, Key, Limit) ->
    ets:select(Tab,
        [{{'$1', '$2'}, [{'==', '$1', Key}], [{{'$1', '$2'}}]}], Limit).

match(Tab, Key) ->
    match(Tab, Key, 1).
match(Tab, Key, Limit) ->
    ets:match(Tab,
        [{{'$1', '$2'}, [{'==', '$1', Key}], [{{'$1', '$2'}}]}], Limit).

match2(Tab, Key) ->
    match2(Tab, Key, 1).

match2(Tab, Key, Limit) ->
    ets:match_object(Tab, {Key, '$1'}, Limit).

ms(HostPort) ->
    ets:fun2ms(
        fun({HostPort2, Time}) when HostPort2 == HostPort ->
            {HostPort2, Time};
            (_) ->
                nothing
        end).

%%%-------------------------------------------------------------------
%%% @author lifang
%%% @copyright (C) 2019, <WISH START>
%%% @doc
%%% 
%%% @end
%%% Created : 2019-08-02 14:09
%%%-------------------------------------------------------------------
-module(log_lab).

-compile(export_all).

debug(Format, Data) ->
    error_logger:info_msg(Format, Data).

ping() ->
    debug("ping()", []),
    debug("add(~p,~p)", [1, 2]).


% use like ?DEBUG_CALL({simple_test, Status, get_value(X)}).
% or even 2 = ?DEBUG_CALL(if true -> 1+1 end).
-define(DEBUG_CALL(Args),
    (
        fun() -> DEBUG_CALL = (Args),
            error_logger:info_msg("~w:~w -> ~s:~n ~150p~n", [?MODULE, ?LINE, ??Args, DEBUG_CALL]), DEBUG_CALL
        end
    )()).


%%-define(make_record_to_list(Record),
%%    record_to_list(Record) ->
%%    Fields = record_info(fields, Record),
%%    [Tag | Values] = tuple_to_list(#Record{}),
%%lists:zip(Fields, Values),
%%).

-define(STACK2(Fun),
    try Fun
    catch
        _:_->
            error_logger:info_msg("~p~n", [erlang:get_stacktrace()]),
            error
    end).

-define(STACK2STACK(Fun),
    begin
        F = fun() -> try Fun
                     catch
                         ERROR:REASON ->
                             error_logger:info_msg("~p:~p ~p~n", [ERROR, REASON, erlang:get_stacktrace()]),
                             error
                     end
            end,
        F()
    end).


test() ->
    ?STACK2(lists:member(1, [])),
    ?STACK2(lists:member(1, [])).

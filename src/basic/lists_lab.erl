%%%-------------------------------------------------------------------
%%% @author lifang
%%% @copyright (C) 2019, <Wish Start>
%%% @doc
%%%
%%% @end
%%% Created : 06. Jun 2019 1:43 PM
%%%-------------------------------------------------------------------
-module(lists_lab).
-author("lifang").

-compile(export_all).
-export([]).

%% 方法一

binary_join(List, Separator) ->
    lists:foldl(
        fun(Item, Acc) ->
            if
                bit_size(Acc) > 0 -> <<Acc/binary, Separator/binary, Item/binary>>;
                true -> Item
            end
        end, <<>>, List).

%% 方法一
%% @doc Join a a list of elements adding a separator between
%%      each of them.
-spec join(iolist(), Sep :: term()) -> iolist().
join([Head | Tail], Sep) ->
    join_list_sep(Tail, Sep, [Head]);
join([], _Sep) ->
    [].

-spec join_list_sep(iolist(), Sep :: term(), Acc :: iolist()) -> iolist().
join_list_sep([Head | Tail], Sep, Acc) ->
    join_list_sep(Tail, Sep, [Head, Sep | Acc]);
join_list_sep([], _Sep, Acc) ->
    lists:reverse(Acc).


%% 方法一
-spec binary_join2([binary()], binary()) -> binary().
binary_join2([], _Sep) ->
    <<>>;
binary_join2([Part], _Sep) ->
    Part;
binary_join2(List, Sep) ->
    lists:foldr(
        fun(A, B) ->
            if
                bit_size(B) > 0 -> <<A/binary, Sep/binary, B/binary>>;
                true -> A
            end
        end, <<>>, List).


% binary_join([<<"Hello">>, <<"World">>], <<", ">>) % => <<"Hello, World">>
% binary_join([<<"Hello">>], <<"...">>) % => <<"Hello">>
% lists:concat(['/erlang/R', 16, "B/lib/erlang/lib/stdlib", "-", "1.19.1/src/lists", '.', erl]).

%% 方法一
%% EXTERNAL

concat(Words, string) ->
    internal_concat(Words);
concat(Words, binary) ->
    list_to_binary(internal_concat(Words)).

%% INTERNAL

internal_concat(Elements) ->
    NonBinaryElements = [case Element of _ when is_binary(Element) -> binary_to_list(Element); _ ->
        Element end || Element <- Elements],
    lists:concat(NonBinaryElements).

%% EUNIT TESTS

-include_lib("eunit/include/eunit.hrl").

concat_conversion_test_() ->
    [
        {"list of strings to string", ?_assertEqual("This and that.", lists_lab:concat(["This", " and", " that."], string))},
        {"list of strings to binary", ?_assertEqual(<<"This and that.">>, lists_lab:concat(["This", " and", " that."], binary))},
        {"list of binaries to string", ?_assertEqual("This and that.", lists_lab:concat([<<"This">>, <<" and">>, <<" that.">>], string))},
        {"list of binaries to binary", ?_assertEqual(<<"This and that.">>, lists_lab:concat([<<"This">>, <<" and">>, <<" that.">>], binary))},
        {"mix of values to string", ?_assertEqual("This and that 5asdf hi.", lists_lab:concat([<<"This">>, " and", <<" that ">>, 5, asdf, " hi."], string))},
        {"mix of values to binary", ?_assertEqual(<<"This and that 5asdf hi.">>, lists_lab:concat([<<"This">>, " and", <<" that ">>, 5, asdf, " hi."], binary))}
    ].


% utils:concat([<<"One">>, " two ", three, 5, 1.25], binary).
% <<"One two three51.25000000000000000000e+00">>

% utils:concat([<<"One">>, " two ", three, 5, 1.25], string).
% "One two three51.25000000000000000000e+00"
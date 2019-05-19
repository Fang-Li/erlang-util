-module(p).

-export([start/0]).

-define(BLK_SIZE, 16384).

start() ->
    do(),
    halt().

do() ->
    Bin = read(),
    io:format("~p~n", [byte_size(Bin)]),
    io:format("~p~n", [Bin]).


read() ->
    ok = io:setopts(standard_io, [binary]),
    read(<<>>).

read(Acc) ->
    case file:read(standard_io, ?BLK_SIZE) of
        {ok, Data} ->
            read(<<Acc/bytes, Data/bytes>>);
        eof ->
            Acc
    end.
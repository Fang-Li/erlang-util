%%%-------------------------------------------------------------------
%%% @author lifang
%%% @copyright (C) 2019, <Wish Start>
%%% @doc
%%%
%%% @end
%%% Created : 19. May 2019 9:14 PM
%%%-------------------------------------------------------------------
-module(array_lab).
-author("lifang").

-compile(export_all).




new(Rows, Cols) ->
    A = array:new(Rows),
    array:map(fun(_X, _T) -> array:new(Cols) end, A).

get(RowI, ColI, A) ->
    io:format("rowi ~p ~p ~p~n", [RowI,ColI,A]),
    Row = array:get(RowI, A),
    array:get(ColI, Row).

set(RowI, ColI, Ele, A) ->
    Row = array:get(RowI, A),
    io:format("row ~p~n", [Row]),
    Row2 = array:set(ColI, Ele, Row),
    array:set(RowI, Row2, A).



new(Data) ->
    init(Data).
init([Row | Data]=Data2) ->
    Rows = erlang:length(Data2) + 1,
    Cols = erlang:length(Row) + 1,
    Array = new(Rows, Cols),
    io:format("arr ~p ~p ~p~n",[Rows,Cols,Array]),
    init(Data, 1, Array).

init([], _RowNum, Array) ->
    Array;
init([Row | Rows], RowNum, Array) ->
    Array2 = lists:foldl(
        fun({ColNum, Col}, Acc) ->
            io:format("col ~p ~p ~p ~p~n ", [RowNum, ColNum, Col, Acc]),
            set(RowNum, ColNum, Col, Acc)
        end, Array, lists:zip(lists:seq(1, erlang:length(Row)), Row)),
    init(Rows, RowNum + 1, Array2).







recur(Data) ->
    recur(Data, {1, 1}).
recur([], {Row, Col}) ->
    {Row - 1, Col};
recur([H | T], {Row, _Col}) ->
    Col = recur(H, Row, 0),
    recur(T, {Row + 1, Col}).

recur([], _Row, Col) ->
    Col;
recur([H | T], Row, Col) ->
    recur(T, Row, Col + 1).




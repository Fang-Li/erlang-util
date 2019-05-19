%%%-------------------------------------------------------------------
%%% @author lifang
%%% @copyright (C) 2019, <Wish Start>
%%% @doc
%%%
%%% @end
%%% Created : 19. May 2019 6:39 PM
%%%-------------------------------------------------------------------
-module(friends_circle).
-author("lifang").

-compile(export_all).

-spec uf1() -> ok.

uf1() ->
    L = [a, b, c, d, e, f, g, h, i, j],
    F = union_find:singletons_from_list(L),
%%  union_find:pprint(F),
    10 = union_find:number_of_sets(F),
    true = union_find:union(F, a, e),
%%  union_find:pprint(F),
    true = union_find:union(F, a, d),
%%  union_find:pprint(F),
    true = union_find:union(F, g, i),
%%  union_find:pprint(F),
    true = union_find:union(F, h, f),
    union_find:pprint(F),
    6 = union_find:number_of_sets(F),
    [a, d, e] = lists:sort(union_find:set_elements(F, e)),
    g = union_find:find(F, i),
    3 = union_find:set_size(F, e),
    true = union_find:delete(F),
    ok.


find_circle_num() ->
    Data = [[1, 1, 0, 0],
        [1, 1, 1, 0],
        [0, 1, 1, 0],
        [0, 1, 1, 0]
    ],
    UserNum = erlang:length(Data),
    Forest = union_find:singletons_from_list(lists:seq(1, UserNum)),
    Array = array_lab:new(Data),
    Fun = fun(A, B) -> case array_lab:get(A, B, Array) == 1 of
                           true -> union_find:union(Forest, union_find:find(Forest, A), union_find:find(Forest, B));
                           _ ->
                               nothing
                       end
          end,
    for(1, UserNum, Fun),
    union_find:pprint(Forest),
    Circles = lists:foldl(
        fun(User, Acc) ->
            [union_find:find(Forest, User), Acc]
        end, [], lists:seq(1, UserNum)),
    CircleNum = erlang:length(lists:usort(Circles)),
    io:format("circles number ~p~n", [CircleNum]),
    Forest.


print(I, J) ->
    io:format("~w,~w~n", [I, J]).

test() ->
    for(1, 3, fun print/2).
for(End, End, F) ->
    F(End, End);
for(Start, End, F) ->
    for(Start, Start + 1, End, F),
    for(Start + 1, End, F).

for(I, J, End, F) when J == End ->
    F(I, J);
for(I, J, _End, F) ->
    F(I, J).
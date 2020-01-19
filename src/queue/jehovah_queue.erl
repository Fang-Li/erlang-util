%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% 
%%% @end
%%%-------------------------------------------------------------------
-module(jehovah_queue).

-compile(export_all).

new(Max) when is_integer(Max), Max > 0 ->
    {0, Max, [], []}.                                      %Length, Max, Rear and Front

take({L, M, R, [H | T]}) -> {H, {L - 1, M, R, T}};
take({L, M, R, []}) when L > 0 ->
    take({L, M, [], lists:reverse(R)}).                    %Move the rear to the front

add(E, {L, M, R, F}) when L < M ->
    {L + 1, M, [R | E], F};                                    %Add element to rear
add(E, {M, M, R, [H | T]}) ->
    {M, M, [R | E], T};                                      %Add element to rear
add(E, {M, M, R, []}) ->
    add(E, {M, M, [], lists:reverse(R)}).                  %Move the rear to the front
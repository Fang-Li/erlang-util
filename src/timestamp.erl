-module(timestamp).
-author("lifang").

-export(
  [
    timestamp/0,
    simple/0
  ]).

timestamp() ->
  {A,B,C} = erlang:timestamp(),
  TimeStamp = integer_to_list(A)++integer_to_list(B)++integer_to_list(C),
  <<E:32,F:32,G:32>> = crypto:strong_rand_bytes(12),
  random:seed(E,F,G),
  Uniform = random:uniform(1000),
  Uniform2 = integer_to_list(Uniform),
  TimeStamp ++ Uniform2.

simple() ->
  {A,B,C} = erlang:timestamp(),
  integer_to_list(A)++integer_to_list(B)++integer_to_list(C).

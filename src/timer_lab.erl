-module(timer_lab).
-compile(export_all).

test() ->
  L = lists:seq(1,30),
  timer:tc(lists,map,[fun(X) -> fib:fib(X) end, L]),
  lists:map(fun(X) -> timer:tc(fib,fib,[X]) end,L),
  timer:tc(lists,map,[fun(X)-> timer:tc(fib,fib,[X]) end,L]).

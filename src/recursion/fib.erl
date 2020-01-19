%%% fib:busy让CPU保持狂运算

-module(fib).
-export([fib/1]).
-compile(export_all).

fib(0) -> 0;
fib(1) -> 1;
%% fib(N) when N>1 -> fib(N-1) + fib(N-2). 

fib(N) -> fib(N-1) + fib(N-2).
busy()-> 
    fib(10), 
    busy().

%%% erl  +sbt db +sub true
%%% Eshell V6.0.1  (abort with ^G)
%%% 1> [spawn(fun()-> fib:busy() end)||_<-lists:seq(1,8)].
%%% [<0.34.0>,<0.35.0>,<0.36.0>,<0.37.0>,<0.38.0>,<0.39.0>,
%%%  <0.40.0>,<0.41.0>]
%%% 2>


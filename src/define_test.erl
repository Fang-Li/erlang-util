-module(define_test).
-compile(export_all).
-define(Jid(User,Resource),{jid,User,Resource,User,Resource}).
-define(TingFlag,lists:member(a,interrupt())).
test() ->
  io:format("~p~n",[?Jid(lifang,xxx)]).

interrupt() ->
	[a].

ting() ->
	?TingFlag.

ting2() ->
%	if ?TingFlag -> ting;
%		true -> no
%	end.
	no.

-define(IF(Cond, E1, E2), (case (Cond) of true -> (E1); false -> (E2) end)). %% 三目运算,三元运算

def_lab() ->
	?IF(true,ting(),666).

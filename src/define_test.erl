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

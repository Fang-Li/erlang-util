-module(define_test).
-compile(export_all).
-define(Jid(User,Resource),{jid,User,Resource,User,Resource}).

test() ->
  io:format("~p~n",[?Jid(lifang,xxx)]).
-module(pool_lab).
-compile(export_all).

%% 3个为一批
-define(N,3).

acc1(String) ->
    [String ++ integer_to_list(I)||I<-lists:seq(1,?N)].

acc(Strings) ->
  %%[acc1(String)||String<-Strings],
  [head(String)||String<-Strings].

a()->
  aa.

head(Arg)->
  head(Arg,0).
head(_Arg,?N)->
  final;
head(Arg,I)->
  Combined=text:concat([Arg,I+1]),
  io:format("~p~n",[Combined]),
  head(Arg,I+1).


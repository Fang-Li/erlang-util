-module(combination).
-compile(export_all).

%% List = [1,2,3]
c2([]) ->
  [];
c2(List) ->
  c2(List,_Sets=[]).
c2([],Sets) ->
  Sets;
c2([H|List],Sets) ->
  case List of
    [] ->
      [{H,H} | Sets];
    [H2|Tail] ->
      Sets2= [{H,H2} | Sets],
      c2(Tail,Sets2)
  end.
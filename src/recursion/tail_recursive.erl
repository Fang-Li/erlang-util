-module(tail_recursive).
-compile(export_all).

recu(List) ->
	recu(List,false).

recu([],Acc) ->
  Acc;
recu(_,{2,{1,false}}) ->
  aaa;
recu([H|T],Acc) ->
 Acc2 = {H,Acc},
  recu(T,Acc2).


bian_jia(_WaiPai, []) ->
  false;
bian_jia(WaiPai, ChiList) ->
  recursive(WaiPai, ChiList, false).

recursive(_WaiPai, [], false) ->
  false;
recursive(_WaiPai, _, true) ->
  true;
recursive(WaiPai, [ChiPai | Tail], false) ->
  Bool = case ChiPai of
          [WaiPai, _, _] ->
            true;
          [_, _, WaiPai] ->
            true;
          _ ->
            false
        end,
  recursive(WaiPai, Tail, Bool).


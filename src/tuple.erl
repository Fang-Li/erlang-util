-module(tuple).
-compile(export_all).

-spec combine(tuple()) -> list().
combine(A) ->
  case A of
    [] -> 
      [];
    _ ->
      combine(odd, A, _Acc = [])
  end.

combine(odd, A, Acc) ->
  [Key|Tail] =  A,
  case Tail of
    [] ->
      [{Key,error}|Acc];
    _ ->
      combine(even, Key, Tail, Acc)
  end.
  
combine(even, Key, A, Acc) ->
  [Value|Tail] = A,
  case Tail of 
    [] ->
      [{Key,Value} | Acc];
    _ ->
      combine(odd, Tail, [{Key,Value} | Acc])
  end.
      
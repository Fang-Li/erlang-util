-module(ets_max).
-compile(export_all).

max() ->
  ets:new(msg,[set,public]),
  max(1).

max(N) ->
  try ets:new(msg,[set,public]),
      max(N+1)
  catch 
      throw:X -> {throw,X,N};
      exit:X -> {exit,X,N};
      error:X -> {error,X,N}
  end.

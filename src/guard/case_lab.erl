-module(case_lab).
-compile(export_all).

lab() ->
  case (1==2) andalso [1,2,3] of
	true ->
		a;
	Arg ->
		Arg
end.

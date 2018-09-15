-module(catch_lab).
-compile(export_all).

catch_lab() ->
	lists:sort(fff).

throws(F) ->
	try F() of
		_ -> ok
	catch
		Throw -> {throw, caught, Throw}
	end.

myproc()->
	timer:sleep(5000),
	exit(reason).

die() ->
	Pid = spawn(fun myproc/0 ),
	%link(spawn(fun myproc/0)), %%不link, 本地shell就不会死,link了会死
	register(pid,Pid).

-module(if_lab).

-compile(export_all).

if_lab(Arg)->

	if Arg ==1 ->
		1;
		2;
		true ->
		 noting
    end.

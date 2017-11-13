-module(recursion).
-compile(export_all).

get_product(1,Product) ->
  Product;
get_product(N,Product) ->
  get_product(N-1,N*Product).

get_sum(1,Sum) ->
  Sum + 1;
get_sum(Number,Sum) ->
  %% Product = get_product(Number,1),
	%% io:format("~p~n",[Product]),
  get_sum(Number-1,get_product(Number,1)+Sum).

	
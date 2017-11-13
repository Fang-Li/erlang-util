-module(worker_test).
-compile(export_all).

start() ->
  {ok,P1} = worker:start(),
	{ok,P2} = packet_ykt:start(),
	{ok,P3} = packet_ypt:start(),
	{P1,P2,P3}.
	
	
test(Args) ->
  worker!Args.
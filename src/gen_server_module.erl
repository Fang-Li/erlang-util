-module(gen_server_module).
-compile(export_all).
test() ->
  io:format("").
  
  
%% behaviour
start(Mod) ->
  spawn(gen_server_module,init,[Mod]).

init(Mod) ->
  register(Mod,self()),
  State = Mod:init(),
  loop(Mod, State).

loop(Mod,State) ->
  receive
    {call, From, Req} ->
      TemRes = Mod:handle_call(Req,State),
      io:format("TemRes .. ~p~n",[TemRes]),
      {Res, State2} = TemRes,
      From ! {Mod, Res},
      loop(Mod, State2);
    {cast, Req} ->
      State2 = Mod:handle_cast(Req,State),
      loop(Mod, State2);
    stop ->
      stop
  end.

call(Name, Req) ->
  Name ! {call, self(), Req},
  receive
    {Name, Res} ->
      Res
  end.
cast(Name,Req) ->
  Name ! {cast, self(), Req},
  ok.
  
  
    


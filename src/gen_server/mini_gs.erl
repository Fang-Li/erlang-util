-module(mini_gs).
-export([start_link/4, call/2]).

%% this module behaves just like the gen-server for a sub-set of the gen_server
%% commands
start_link({local,Name}, Mod, Args, _Opts) ->
    register(Name, spawn(fun() -> start(Mod, Args) end)).
call(Name, X) ->
    Name ! {self(), Ref = make_ref(), X},
    receive
     {Ref, Reply} -> Reply
    end.
start(Mod, Args) ->
   {ok, State} = Mod:init(Args),
   loop(Mod, State).
loop(Mod, State) ->
   receive
   {From, Tag, X} ->
      case Mod:handle_call(X, From, State) of
      {reply, R, State1} ->
          From ! {Tag, R},
          loop(Mod, State1)
      end
  end.
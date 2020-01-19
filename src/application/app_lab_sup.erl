-module(app_lab_sup).  
  
-behaviour(supervisor).  
  
-export([start_link/1, init/1]).  
  
start_link(_) ->  
    io:format("test sup start link~n"),  
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).  
  
  
init([]) ->  
    io:format("app_lab_sup init~n"),  
    {ok,{  
        {one_for_one, 1, 1},  
        [{id,{my_supervisor,restart,[]},permanent,brutal_kill,worker,[]}]}  
    }.
-module(eknife_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILDWORK(I), {I, {I, start_link, []}, permanent, 5000, worker, [I]}).
-define(CHILDSUP(I), {I, {I, start_link, []}, permanent, infinity, supervisor, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    {ok,
        {
            {one_for_one, 5, 10},
            [
                ?CHILDWORK(eknife_timer)
            ]
        }
    }.


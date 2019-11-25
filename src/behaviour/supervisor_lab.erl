-module(supervisor_lab).
-compile(export_all).
-define(CHILDWORK(I), {I, {I, start_link, []}, permanent, 5000, worker, [I]}).
-behaviour(supervisor).

start() ->
    supervisor:start_link({local, supervisor_lab}, supervisor_lab, []).

init(_) ->
    {ok,
        {
            {one_for_one, 1, 1},
            [?CHILDWORK(supervisor_lab_child_not_link)]
        }
    }.


start_child() ->
    supervisor:start_child(supervisor_lab, ?CHILDWORK(supervisor_lab_child)).

start_child_not_link() ->
    supervisor:start_child(supervisor_lab, ?CHILDWORK(supervisor_lab_child_not_link)).


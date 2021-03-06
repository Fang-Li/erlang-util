-module(kill).
-compile(export_all).


%% 是否能够监控到进程退出
start() ->
    F =
        fun() ->
            %%process_flag(trap_exit, true),
            receive
                {R, Ref, _, _, _} ->
                    io:format("~p~n", [{R, Ref}]),
                    file:write_file('kill.log', R, [append]),
                    file:write_file('kill.log', "\n"),
                    {R, Ref};
                R ->
                    io:format("1"),
                    % {A,P,B} = R,
                    io:format("reason:~p~n", [R]),
                    file:write_file('kill.log', R, [append]),
                    file:write_file('kill.log', "\n"),
                    R
            end
        end,
    spawn_link(F).

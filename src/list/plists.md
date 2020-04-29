% Any of the above may be used as a malt, or may be combined into a list.
% {nodes, NodeList} and {processes, X} may not be combined.
%
% === Examples ===
% % start a process for each element (1-element sublists)<br/>
% 1
%
% % start a process for each ten elements (10-element sublists)<br/>
% 10
%
% % split the list into two sublists and process in two processes<br/>
% {processes, 2}
%
% % split the list into X sublists and process in X processes,<br/>
% % where X is the number of cores in the machine<br/>
% {processes, schedulers}
%
% % split the list into 10-element sublists and process in two processes<br/>
% [10, {processes, 2}]
%
% % timeout after one second. Assumes that a process should be started<br/>
% % for each element.<br/>
% {timeout, 1000}
%
% % Runs 3 processes at a time on apple@desktop,
% and 2 on orange@laptop<br/>
% % This is the best way to utilize all the CPU-power of a dual-core<br/>
% % desktop and a single-core laptop. Assumes that the list should be<br/>
% % split into 1-element sublists.<br/>
% {nodes, [{apple@desktop, 3}, {orange@laptop, 2}]}
%
% Like above, but makes plists figure out how many processes to use.
% {nodes, [{apple@desktop, schedulers}, {orange@laptop, schedulers}]}
%
% % Gives apple and orange three seconds to process the list as<br/>
% % 100-element sublists.<br/>
% [100, {timeout, 3000}, {nodes, [{apple@desktop, 3}, {orange@laptop, 2}]}]
%
% === Aside: Why Malt? ===
% I needed a word for this concept, so maybe my subconsciousness gave me one by
% making me misspell multiply. Maybe it is an acronym for Malt is A List
% Tearing Specification. Maybe it is a beer metaphor, suggesting that code
% only runs in parallel if bribed with spirits. It's jargon, learn it
% or you can't be part of the in-group.
%
% == Messages and Errors ==
% plists assures that no extraneous messages are left in or will later
% enter the message queue. This is guaranteed even in the event of an error.
%
% Errors in spawned processes are caught and propagated to the calling
% process. If you invoke
%
% plists:map(fun (X) -> 1/X end, [1, 2, 3, 0]).
%
% you get a badarith error, exactly like when you use lists:map.

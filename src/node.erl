-module(node).
-compile(export_all).

remote(OtherNode)->
% get the PID of the user server on OtherNode
RemoteUser = rpc:call(OtherNode, erlang,whereis,[user]), 

true = is_pid(RemoteUser),

% send message to remote PID
RemoteUser ! ignore_this, 

% print "Hello from <nodename>\n" on the remote node's console.
io:format(RemoteUser, "Hello from ~p~n", [node()]). 

% Module:
% user
% Summary:
% Standard I/O server.
% Description:
% user is a server that responds to all messages defined in the I/O interface. The code in user.erl can be used as a model for building % alternative I/O servers.
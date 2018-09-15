-module(reloader_lab).

-export([loop/0]).

loop() ->
    receive
        upgrade ->
            code:purge(?MODULE),
            compile:file(?MODULE),
            code:load_file(?MODULE),
            ?MODULE:loop();
        hello ->
            io:format("This is a test~n"),
            % io:format("I have changed this!~n"),
            loop();
        _ ->
            loop()
    end.


% Eshell V5.9.1  (abort with ^G)
% 1> Loop = spawn(reloading, loop, []).
% <0.34.0>
% 2> Loop ! hello.
% This is a test
% hello

% Change line to io:format("I have changed this!~n"),
% 
% 3> Loop ! upgrade.                   
% upgrade
% 4> Loop ! hello.  
% I have changed this!
% hello

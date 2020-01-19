-module(test_parse_trans).
-export([start/0]).
-compile({parse_transform, parse_trans}).

start() ->

    new().
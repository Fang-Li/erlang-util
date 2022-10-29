%%%-------------------------------------------------------------------
%%% @author dosec
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 4月 2022 20:54
%%%-------------------------------------------------------------------
-module(ftp_lab).
-author("dosec").

%% API
-export([start/0]).

start() ->
  ReceivePid = spawn(
    fun() ->
      receive
        Response -> io:format("connect success", Response)
      after 50 -> io:format("connect timeout")
      end
    end),

  spawn(
    fun() ->
      Res = timer:sleep(10),
      io:format(Res),
      ReceivePid ! Res
    end).

%%%-------------------------------------------------------------------
%%% @author lifang
%%% @copyright (C) 2018, <Wish Start>
%%% @doc
%%%
%%% @end
%%% Created : 16. 九月 2018 上午2:06
%%%-------------------------------------------------------------------
-module(eunit_auto).
-author("lifang").
-include_lib("eunit/include/eunit.hrl").

-export([add/2]).

add(A,B) -> A + B.

add_test() ->
  4 = eunit_auto:add(2,2).
%%%-------------------------------------------------------------------
%%% @author lifang
%%% @copyright (C) 2018, <Wish Start>
%%% @doc
%%%
%%% @end
%%% Created : 16. 九月 2018 上午1:19
%%%-------------------------------------------------------------------
-module(eunit_lab).
-author("lifang").

-export([]).
%%-define(NOTEST, 1).
-include_lib("eunit/include/eunit.hrl").

%% 简单测试
reverse_test() -> lists:reverse([1,2,3]).

%% 加入验证
reverse_nil_test() -> [] = lists:reverse([]).
reverse_one_test() -> [1] = lists:reverse([1]).
reverse_two_test() -> [2,1] = lists:reverse([1,2]).


%% 优雅验证
length_test() -> ?assert(length([1,2,3]) =:= 3).

%% 生成函数
basic_test_() ->
  fun () -> ?assert(1 + 1 =:= 2) end.


%% 格式紧凑点
basic2_test_() ->
  ?_test(?assert(1 + 1 =:= 2)).

basic3_test_() ->
  ?_assert(1 + 1 =:= 2).


%% 有了生成函数, 不会执行普通函数了

add_test_() ->
  [test_them_types(),
    test_them_values(),
    ?_assertError(badarith, 1/0)].

test_them_types() ->
  ?_assert(is_number(ops:add(1,2))).

test_them_values() ->
  [?_assertEqual(4, ops:add(2,2)),
    ?_assertEqual(3, ops:add(1,2)),
    ?_assertEqual(3, ops:add(1,1))].


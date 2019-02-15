%%%-------------------------------------------------------------------
%%% @author lifang
%%% @copyright (C) 2019, <Wish Start>
%%% @doc
%%%
%%% @end
%%% Created : 25. Jan 2019 6:19 PM
%%%-------------------------------------------------------------------
-module(binary_lab).
-author("lifang").

-compile(export_all).

%% erlang 位语法

%% 把手机号或UID中间位替换为****

replace(Binary) when is_binary(Binary) ->
  replace(binary_to_list(Binary)).

replace(List) when length(List) > 3 ->
  ok;

replace(<<"">>) ->
  <<"">>.



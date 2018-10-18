-module(user_default).
-compile(export_all).
-record(foo,{id,name,bar}).
-include("include/ejabberd.hrl").

get_meta() -> 
  user_default:module_info().
get_timestamp() ->
  {M, S, _} = erlang:timestamp(), 
  M * 1000000 + S.

-module(user_default).
-compile(export_all).
-record(book,{name, id, item01, item02, item03, item04, item05, item06, item07, item08, item09, item10 } ).
-record(film,{director,actor,type,name,imdb}).
-record(foo,{id,name,bar}).
-include("include/ejabberd.hrl").

get_meta() -> 
  user_default:module_info().
get_timestamp() ->
  {M, S, _} = erlang:now(), 
  M * 1000000 + S.
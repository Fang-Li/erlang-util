-module(include).
-compile(export_all).
-include("include/hello.hrl").

-record(state2,{
  a,
  b,
  c
}).

test() ->
  
  error_logger:info_msg(record,#state{}).
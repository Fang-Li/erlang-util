-module(my_callback).
-export([behaviour_info/1]).

%-callback messages() -> {OK::atom(), Closed::atom(), Error::atom()}.

behaviour_info(callbacks)->
    [{foo,0},{bar,1},baz,2];
behaviour_info(_) ->
    undefined.


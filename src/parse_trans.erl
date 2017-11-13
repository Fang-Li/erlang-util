-module(parse_trans).
-export([parse_transform/2, format_error/1]).

parse_transform(Forms, Options) ->
    io:format("parse_trans .. 1 file = ~p~n", [Forms]),
    io:format("parse_trans .. 2 option = ~p~n", [Options]),

    NewForms = 
    lists:append(
      lists:map(
        fun transform_form/1,
        Forms
       )
     ),
     io:format("parse_trans .. 3 NewForms = ~p~n", [NewForms]),
     NewForms.
     
transform_form({eof, Line} = Form) ->
    io:format("transform_form .. 1 Form = ~p~n",[Line]),
    io:format("transform_form .. 2 Line = ~p~n",[Line]),
    [
     %% Append function new/0 in the end of the module
     {function,Line,new,0,[{clause,Line,[],[],[{atom,Line,test}]}]},
     Form
    ];
transform_form(Form) ->
    io:format("transform_form .. 3 Form = ~p~n",[Form]),
    [Form].

format_error(E) ->
    io:format("format_error .. 1 Error = ~p~n",[E]),
    case io_lib:deep_char_list(E) of
        true ->
            E;
        _ ->
            io_lib:write(E)
    end.
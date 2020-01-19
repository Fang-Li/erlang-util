-module(transform_lab).  
-export([parse_transform/2]).  
  
  
parse_transform(AST, _Options) ->  
    walk_ast([], AST).  
  
walk_ast(Acc, []) ->  
    lists:reverse(Acc);  
walk_ast(Acc, [{function, Line, Name, Arity, Clauses}|T]) ->  
    walk_ast([{function, Line, Name, Arity,  
                walk_clauses([], Clauses)}|Acc], T);  
walk_ast(Acc, [H|L]) ->  
    walk_ast([H|Acc], L).  
  
walk_clauses(Acc, []) ->  
    lists:reverse(Acc);  
walk_clauses(Acc, [{clause, Line, Arguments, Guards, Body}|T]) ->  
    walk_clauses([{clause, Line, Arguments, Guards, walk_body([], Body)}|Acc], T).  
  
walk_body(Acc, []) ->  
    lists:reverse(Acc);  
walk_body(Acc, [H|T]) ->  
    walk_body([transform_statement(H)|Acc], T).  
  
transform_statement({match, Line, {var, Line, 'A'}, {integer, Line, _V}}) ->  
    {match, Line, {var, Line, 'A'}, {integer, Line, 2}};  
transform_statement(Stmt) when is_tuple(Stmt) ->  
    list_to_tuple(transform_statement(tuple_to_list(Stmt)));  
transform_statement(Stmt) when is_list(Stmt) ->  
    [transform_statement(S) || S <- Stmt];  
transform_statement(Stmt) ->  
    Stmt. 
    
    
%% transform_lab 的作用是把语句A = 1替换成A = 2.

%% 测试结果：
%% (master@127.0.0.1)18> c(test).                                            
%% {ok,test}
%% (master@127.0.0.1)19> test:main().
%% A: 1
%% ok
%% (master@127.0.0.1)20> c(test_transform).
%% {ok,test_transform}
%% (master@127.0.0.1)21> c(test, [{parse_transform,test_transform}]).
%% {ok,test}
%% (master@127.0.0.1)22> test:main().
%% A: 2
%% ok
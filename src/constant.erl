-module(constant).
-export([compile/2]).
%% 导出模块内指定方法用于调试，返回指定值
%% Erlang共享常量一种实现方式

compile(Mod, KVList) ->
    Bin = makes(Mod, KVList),
    code:purge(Mod),
    {module, Mod} = code:load_binary(Mod, atom_to_list(Mod) ++ ".erl", Bin),
    ok.

makes(Module, KVList) ->
    {ok, Module, Bin} = compile:forms(forms(Module, KVList),
                                      [verbose, report_errors]),
    Bin.

forms(Module, KVList) ->
    [erl_syntax:revert(X) || X <- term_to_abstract(Module, KVList)].

term_to_abstract(Module, KVList) ->
    ModuleName = erl_syntax:attribute(
                     erl_syntax:atom(module),
                     [erl_syntax:atom(Module)]),
              
    Export = erl_syntax:attribute(
                 erl_syntax:atom(export),
                 [erl_syntax:list(
                      [erl_syntax:arity_qualifier(
                       erl_syntax:atom(K),
                       erl_syntax:integer(0)) || {K, _} <- KVList])]),

    Functions = [erl_syntax:function(
                    erl_syntax:atom(K),
                    [erl_syntax:clause([], none, [erl_syntax:abstract(V)])]) || {K, V} <- KVList],

    [ModuleName, Export | Functions].

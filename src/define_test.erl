-module(define_test).
-compile(export_all).
-define(Jid(User, Resource), {jid, User, Resource, User, Resource}).

-define(JA(Atom), list_to_atom("ja_" ++ atom_to_list(Atom))).
-define(JB(Bin), begin binary_to_atom(<<"jb_", Bin/binary>>, latin1) end).
-define(JC(Atom), begin
                      Bin = atom_to_binary(a, latin1),
                      binary_to_atom(<<"jc_", Bin/binary>>, latin1)
                  end).

-define(TingFlag, lists:member(a, interrupt())).

test() ->
    io:format("~p~n", [?Jid(lifang, xxx)]).

interrupt() ->
    [a].

ting() ->
    ?TingFlag.

ting2() ->
%	if ?TingFlag -> ting;
%		true -> no
%	end.
    no.

-define(IF(Cond, E1, E2), (case (Cond) of true -> (E1); false -> (E2) end)). %% 三目运算,三元运算

def_lab() ->
    ?IF(true, ting(), 666).


-define(Stack(Fun), try Fun
                    catch
                        ERROR:REASON ->
                            io:format("~p:~p ~p~n", [ERROR, REASON, erlang:get_stacktrace()]),
                            error
                    end).


stack() ->
    ?Stack(?MODULE:interrupt()).

stack2() ->
    case ?Stack(a:b(c)) of
        a ->
            a;
        ok ->
            b;
        AA ->
            AA
    end.


-define(Print(Fun), io:format("~p~n", [Fun])).
print_fun() ->
    ?Print(a:b(c)).


-ifdef(debug).
-define(LOG(X), io:format("{~p,~p}: ~p~n", [?MODULE, ?LINE, X])).
-else.
-define(LOG(X), true).
-endif.

-define(test, true).
-ifdef(test).
-define(LOG2(X), io:format("{~p,~p}: ~p~n", [?MODULE, ?LINE, X])).
-else.
-define(LOG2(X), true).
-endif.

%% 以下三种方法可以预定义宏debug或test
%% c(m, {d, debug}).
%% erlc -Ddebug m.erl
%% make:files(["src/define_test"],[{d,debug},{d,test}]).

ifdef() ->
    ?LOG(aa),
    ?LOG2(bb).


-define(Backup(Channel, UnionID), begin Time = ekife_time:time_format(time()), <<"backup#", Time/binary>> end).

time_lab() ->
    ?Backup(<<"xian">>, <<"uid">>). %% 不好使

atom(A) ->
    ?JA(A).

bin(B) ->
    ?JB(B).
b(C) ->
    ?JC(C).

perfa() ->
    performance_test:main(fun atom/1, a).
perfb() ->
    performance_test:main(fun bin/1, <<"a">>).
perfc() ->
    performance_test:main(fun b/1, a).
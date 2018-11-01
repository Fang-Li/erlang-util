-module(when_lab).
-compile(export_all).

-record(jid, {user, server, resource, luser, lserver, lresource}).
-record(a,{a,b}).
-record(b,{a=1,b}).

%% test(X) when is_group_chat(X) == true ->
test(X) when X == true ->
  false;
test(_X) ->
  true.


%% 模式匹配
handle("aa") ->
  aabb;
handle(#jid{user="123"}) ->
  user123;
handle(#jid{lserver=[H1,H2,H3|_Doamin]}) when [H1,H2,H3] == "gro" ->
  false;


% 不能这样用
%handle(String) when (string:sub_string(String,1,3) == "con") ->
%  "con";
handle([A|_]) when [A]=="c" ->
  "c";
handle({[A,B|_],[C,D|_]}) when ([A,B] =="co") orelse ([C,D]=="co") ->
  "co";
handle(String) ->
  String.

% 8> 
% 8> when_lab:handle({"confer","aadad"}).
% "co"
% 9> when_lab:handle({"afer","codad"}).  
% "co"
% 10> when_lab:handle({"afer","dad"}).  
% {"afer","dad"}
% 11> 


is_group_chat(#jid{server=Domain}=_To)->
	DomainTokens = string:tokens(Domain,"."),
	_Rtn = case length(DomainTokens) > 2 of 
		true ->
			[G|_] = DomainTokens,
			(G=:="group") or (G =:= "super_group");
		_ ->
			false
  end .
  
%% 对初始值是不做模式匹配的,无论初始值是空或者有值
record(A=#a{a=1})->
  A;
record(A=#b{})->
    A.


get_level() ->
  1.

%guard() ->
%  if get_level() > 1 -> a;
%     true -> b 
%  end.




-record(cross_pos, {
  pao = 0 %% 点炮的那位勇士
}).

rd_lab(Pos) ->
	do_rd(Pos,#cross_pos{pao = 1}).
do_rd(Pos,#cross_pos{pao=Pos}) ->
 equal;
do_rd(Pos,_) ->
 no_equal.

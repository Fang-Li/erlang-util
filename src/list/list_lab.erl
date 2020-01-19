-module(list_lab).
-compile(export_all).

list_lab() ->
	ToBeSelected = [{interrupt_Hu_Tian,true},{interrupt_Hu_Di,false},{interrupt_Hu_Gangkai,true}],
	ToBeSelected2 = [ HuType || {HuType,Bool}<-ToBeSelected,Bool == true],
  	ToBeSelected3 = [optimalHuType | ToBeSelected2].

%% 补零操作,从左侧补充和从左侧截取
padl(List,Length,Char) ->
	do_padl(lists:reverse(List),Length,Char,[]).

do_padl(_List,0,_Char,Acc)  ->
	Acc;
do_padl([],Length,Char,Acc) ->
	[Char||_N<-lists:seq(1,Length)] ++ Acc;
do_padl([H|T],Length,Char,Acc) ->
	do_padl(T,Length-1,Char,[H|Acc]).

%% 补零操作,从右侧补充和从右侧截取
padr(List,Length,Char) ->
	do_padr(lists:reverse(List),Length,Char,[]).

do_padr(_List,0,_Char,Acc) ->
	Acc;
do_padr([],Length,Char,Acc) ->
	Acc ++  [Char||_N<-lists:seq(1,Length)];
do_padr([H|T],Length,Char,Acc) ->
	do_padr(T,Length-1,Char,[H|Acc]).


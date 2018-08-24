-module(list_lab).
-compile(export_all).

list_lab() ->
	ToBeSelected = [{interrupt_Hu_Tian,true},{interrupt_Hu_Di,false},{interrupt_Hu_Gangkai,true}],
	ToBeSelected2 = [ HuType || {HuType,Bool}<-ToBeSelected,Bool == true],
  	ToBeSelected3 = [optimalHuType | ToBeSelected2].

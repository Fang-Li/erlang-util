-module(recursion2).
-compile(export_all).
sum() ->
	[SumFac,_] = 
	 lists:foldl( 
	    fun(X,[Sum,LastFactorial]) ->  
		    NowFactorial = LastFactorial * X,  
			  [Sum+NowFactorial,NowFactorial] 
		 end,[_Sum = 0,_LastFactorial = 1],
	 lists:seq(1,100)) ,
	SumFac.

	
	
sum(N) ->
	[SumFac,_] = 
	 lists:foldl( 
	    fun(X,[Sum,LastFactorial]) ->  
		    NowFactorial = LastFactorial * X,  
			  [Sum+NowFactorial,NowFactorial] 
		 end,[_Sum = 0,_LastFactorial = 1],
	 lists:seq(1,N)) ,
	SumFac.
	
	
%% 阶乘累加的高效算法

%% fprof:apply(recursion2,sum,[10000]), fprof:profile(), fprof:analyse({dest,"recursion2.analyse"}).
%% fprof:apply(recursion,get_sum,[1000,0]), fprof:profile(), fprof:analyse({dest,"recursion.analyse"}). 
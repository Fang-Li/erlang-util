-module(a).  
  
-behaviour(gen_server).  
  
%%External exports  
-export([start_server/0,handle_test/1]).  
  
%% gen_server callbacks  
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).  
  
-record(state, {}).  
  
%% ====================================================================  
%% Server functions  
%% ====================================================================  
  
init([]) ->  
    {ok, #state{},2000}.  
  
  
handle_call({first,Data},_From,State)->  
    case Data of
      0 ->
        1/0;
      _ ->
        ok
    end,
    gen_server:call(b,{second,Data}),
    {reply,Data,State};  
handle_call(_Request,_From,State)->  
    Reply = ok,  
    {reply,Reply,State}.  
      
handle_cast(Msg, State) ->  
    {noreply, State}.  
      
handle_info(Info, State) -> 
    io:format("timeout 2seconds .. ~p~n",[Info]), 
    {noreply, State,2000}.  
      
terminate(Reason, State) ->  
    io:format("who killed me .. ~p",[Reason]),
    ok.  
      
code_change(OldVsn, State, Extra) ->  
    {ok, State}.  
  
%% ====================================================================  
%% Server functions  
%% ====================================================================  
start_server()->  
    gen_server:start_link({local, ?MODULE},?MODULE, [], []).  
      
handle_test(Data) ->  
    gen_server:call(?MODULE,{first,Data}).  
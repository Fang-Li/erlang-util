-module(b).  
  
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
    {ok, #state{}}.  
  
  
handle_call({second,Data},_From,State)->  
    case Data of
      0.0 ->
        2/0;
      _ ->
        ok
    end,
    {reply,Data,State};  
handle_call(_Request,_From,State)->  
    Reply = ok,  
    {reply,Reply,State}.  
      
handle_cast(Msg, State) ->  
    {noreply, State}.  
      
handle_info(Info, State) ->  
    {noreply, State}.  
      
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
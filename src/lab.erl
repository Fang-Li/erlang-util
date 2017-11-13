-module(lab).
-behaviour(gen_server).

-export([init/1,        handle_call/3, 
         handle_cast/2, handle_info/2, 
         terminate/2,   code_change/3]).
-compile(export_all).
-record(state, {}). 

start_link(Server) -> 
    gen_server:start_link({local, Server}, ?MODULE, [], []).

init([]) -> 
    ets:new(jobs, [named_table, public]),

    

    {ok, #state{}}.
%% 添加job Mod
handle_call({addJob, {Mod,Fun,Arg}}, _From, State) -> 
    ets:insert(jobs,{Mod,Fun,Arg}),
    {reply, ets:tab2list(jobs), State};

%% 删除job Mod
handle_call({delJob,Mod}, _From, State) -> 
    ets:delete(jobs,Mod),
    {reply, ets:tab2list(jobs), State};

%% 查询job Mod
handle_call({find,Mod}, _From, State) -> 
    [Job] = ets:lookup(jobs,Mod),
    {reply, Job, State};

%% 所有jobs
handle_call(all, _From, State) -> 
    {reply, ets:tab2list(jobs), State};

%% 其他
handle_call(_Args, _From, State) -> 
    {reply, "bad_args", State}.


handle_cast(_Msg, State) -> 
    {noreply, State}.

handle_info(_Info, State) -> 
    {noreply, State}.

terminate(_Reason, _State) -> 
    ok.

code_change(_OldVsn, State, _Extra) -> 
    {ok, State}.

%% 定时任务
%% 发送指令
%% 还有写个工作的任务 可以增加工作 mod fun arg

%%store()->
%%    ets:new(jobs, [named_table, public]).
%%    ets:insert(jobs,{job1,m,f,arg}).
%%    ets:lookup(jobs, job1).
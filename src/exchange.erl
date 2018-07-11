%% 实时查询交易所代币价格
%% 设定价格查询邮件提醒
%% 当价位波动剧烈的时候，提醒自己关注


-module(exchange).
-compile(export_all).
-define(TIME,5*1000).
-define(PRICE,0.000125).
-record(state,{
  cur,
  max,
  min
}).
-type state() :: #state{}.
%% 发送邮件提醒
send(Price) ->
  From = "649505671@qq.com",
  To = ["13522360889@qq.com"],
  Packet = "Subject: price:"++ binary_to_list(Price) ++"\r\nFrom: huobi \r\nTo: Some Dude \r\n\r\n notice",
  Server = "smtp.qq.com",
  Passwd = "ll135089",
  gen_smtp_client:send({From,To,Packet},[{relay, Server},{username, From}, {password, Passwd}]).

start() ->
  start(?MODULE).
start(Mod) ->
  spawn_link(?MODULE,init,[Mod]).

init(Mod) ->
    register(Mod,self()),
    erlang:send_after(?TIME,self(),loop),
    loop(Mod, #state{}).

loop(Mod,State) ->
  receive 
    loop -> 
      io:format("loop~n",[]),
      State2 = crontab(State),
      erlang:send_after(?TIME,self(),loop),
      loop(Mod,State2);
    {max,Max} ->
      #state{max=OldMax} = State,
      State2 = State#state{max=Max},
      io:format("max :  ~p -> ~p~n",[OldMax,Max]),
      loop(Mod,State2);
    {min,Min} ->
      #state{min=OldMin} = State,
      State2 = State#state{min = Min},
      io:format("min :  ~p -> ~p~n",[OldMin,Min]),
      loop(Mod,State2);
    stop ->
      stop;
    _Arg -> 
      #state{cur=Cur,max=Max,min=Min} = State,
      io:format("~ncur:~p~nmax:~p~nmin:~p~n~n",[Cur,Max,Min]),
      erlang:send_after(?TIME,self(),loop),
      loop(Mod,State)
  end.

-spec crontab(state()) -> state() .
crontab(State) ->
  Current = current(),
  mmax(Current,State),
  mmin(Current,State),
  State#state{cur=Current}.

mmax(undefined,_) ->
  undefined;
mmax(_Cur,#state{max=undefined})->
  undefined;
mmax(Cur,#state{max=Max}) ->
  case Cur>=Max of
    true -> send(Cur);
    _ -> undefined
  end.

mmin(undefined,_) ->
  undefined;
mmin(_Cur,#state{min=undefined}) ->
  undefined;
mmin(Cur,#state{min=Min}) ->
  case Cur =< Min of
    true -> send(Cur);
    _ -> undefined
  end.
current() ->
  1.
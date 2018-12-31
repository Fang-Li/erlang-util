%%% Purpose : ejabberd 插件模块启动
%%% 1. ets同步过程
%%% 2. 模块启动过程
%%% 3. ets的key指定位置的使用方法
%%% 4. 不用重启修改ets中muc配置
%%%----------------------------------------------------------------------

-module(gen_mod).
-export([behaviour_info/1]).
-compile(export_all).
-record(ejabberd_module, {module_host, opts}).
behaviour_info(callbacks) ->
  [{start, 2},
   {stop, 1}];
behaviour_info(_Other) ->
  undefined.
start() ->
  ets:new(ejabberd_modules, [named_table,
           public,
           {keypos, #ejabberd_module.module_host}]),
  io:format("keypos .. ~p~n",[#ejabberd_module.module_host]),
  ok.

start_module(Host, Module, Opts) ->
  ets:insert(ejabberd_modules,
       #ejabberd_module{module_host = {Module, Host},
      opts = Opts}),
  try Module:start(Host, Opts)
  catch Class:Reason ->
    io:format("Class..~p~nReason..~p~n",[Class,Reason])
end.

set_max_users(MaxUsers) ->
    [{ejabberd_module,{mod_muc,"firefly.com"},Opt}] = ets:lookup(ejabberd_modules, {mod_muc, "firefly.com"}),
    lists:keyreplace(max_users,1,Opt,{max_users,MaxUsers}).
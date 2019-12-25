%%%-------------------------------------------------------------------
%%% @author lifang
%%% @doc
%%% 
%%% @end
%%%-------------------------------------------------------------------
-module(recordfields).
-compile(export_all).
-include("ejabberd.hrl").
-include("function.hrl").

%%get(RecordName) ->
%%    record_info(fields, RecordName).


%% record_info 只存在于编译器, 意味着不能使用变量

%% 考虑到 define macro 也是编译期的，我们可以这样 trick


-record(test, {
    a :: binary(),
    b :: binary()
}).

-define(RecordFields(RecordName),
    fun(RecordName) ->
        record_info(fields, RecordName)
    end
).

%% 此函数也只是在编译器的时候,把当前参数编译出来了而已,同样适配任意record
getfields() ->
    ?RecordFields(test),
    ?RecordFields(jid).

%% thrift使用的是导出到文件里面来做的 ServiceName:function_info(FuncName, params_type)
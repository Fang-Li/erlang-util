#!/bin/bash

## 节点名称@ip

local=`dirname $0`
localip=`bin/ip.sh`
NODE=`$local/dir.sh`
echo `echo "\""$localip`"\"." > ~/.hosts.erlang
NODENAME="$NODE@$localip"

## 启动并加载所有模块,可以实现用table键快速执行模块函数
erl -pa $local/../ebin $local/../deps/*/ebin  \
	+zdbbl 1048576 \
	+MMscs 1024 \
	+MMscrpm true \
	+spp true \
	-env ERL_NO_VFORK 1 \
    +K true -smp \
    +swct eager \
    -eval "{ok,FileLists} = file:list_dir(ebin), \
	    try \
	        [ begin \
		        [File|Suffix] = string:tokens(FileName,\".\") , \
		        case Suffix == [\"beam\"] of \
			        true -> File2 = erlang:list_to_atom(File); \
			        _ -> File2 = erlang \
		        end, \
		        erlang:apply(File2,module_info,[]) \
	          end  ||  FileName <- FileLists , FileName =/= \"nif_c.beam\"], \
	        make:all([{compile,export_all},debug_info]) \
	    catch ERROR:REASON -> \
			io:format(\"stack .. ~p~n\",[erlang:get_stacktrace()]), \
			io:format(\"~p:~p~n\",[ERROR,REASON]) \
	    end." \
	-s reloader \
    -name $NODENAME \
    -setcookie eknife \
    #-detached #默认不以detach启动

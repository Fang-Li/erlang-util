#!/bin/bash

## 获取内网地址的方法
#card="wlan0"
#card="eth0"
#localip=`ifconfig $card|sed -n 2p|awk  '{ print $2 }'|awk -F : '{ print $2 }'`
localip=127.0.0.1 ## 默认的本地地址
local=`dirname $0` ## 当前文件夹的路径
NODE=${PWD##*/} ## 获取文件夹的名称,作为节点名称
NODENAME="$NODE@$localip" ## 长节点名称

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





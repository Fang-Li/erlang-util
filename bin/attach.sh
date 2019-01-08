#!/bin/bash

## 生成节点名称,以文件夹的名称命名,便携
if [ "$1" = "" ]; then
        NODE=${PWD##*/}
else
        NODE=$1
fi
echo $NODE
## 项目以eknife的节点名称接入远程节点调试
erl -name eknife$RANDOM@127.0.0.1 -remsh $NODE@127.0.0.1 -setcookie eknife

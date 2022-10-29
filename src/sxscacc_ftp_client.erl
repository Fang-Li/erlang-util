%% coding: latin-1
%% @desc	:FTP Client封装。

-module(sxscacc_ftp_client).
-author('libing.zhi@ergchina.com').
-vsn        ("2.3.0.1").
-export([open/4, close/1,
  upload/2, upload/3, download/1, download/3, rename/2, delete_file/1,
  delete_dir/1, ensure_dir/1, enum_files/3, is_exist/1]).

%% =============================================================================================================
%% API functions
%% =============================================================================================================
%% 建立ftp连接
%% 输入参数：
%%		Host，ftp服务器地址；
%%		Port，ftp服务器端口号；
%%		User，用户;
%%		Password，用户密码。
%% 示例：sxscacc_ftp_client:open("10.247.57.22",21,"ftp","erg")。


call(GenServer, Msg, Format, Timeout) ->
  Req = {self(), Msg},
  case (catch gen_server:call(GenServer, Req, Timeout)) of
    {ok, Bin} when is_binary(Bin) andalso (Format =:= string) ->
      {ok, binary_to_list(Bin)};
    {'EXIT', _, _} ->
      {error, eclosed};
    {'EXIT', _} ->
      {error, eclosed};
    Result ->
      Result
  end.

open(Host, Port, User, Password) ->
  % {ok, DeviceId} = application:get_env(deviceId),
  % Time =  list_to_integer(string:substr(DeviceId,6,1)) * 1000,
  % timer:sleep(Time),
  log4erl:info("*** ~p(~4.10.0w)  Opening a connection to the ftp server ...~n", [?MODULE, ?LINE]),
  log4erl:info("*** ~p(~4.10.0w) Host=~p ...~n", [?MODULE, ?LINE, Host]),
  {Status, Pid} = ftp:open(Host, [{port, Port}, {timeout, 5000}]),
%%  call(Pid, {user, User, Pass}, atom)
  if
    ftp:ls(),
    Status =:= ok ->
      call(Pid, {user, User, Password}, atom, 5000);


% Result = ftp:user(Pid,User, Password),
% if
% 	Result =:= ok	->
% 		put(pid,Pid),
% 		log4erl:info("*** ~p(~4.10.0w) The connection has been established successfully!~n",[?MODULE, ?LINE]),
% 		{ok, Pid};
% 	true	->
% 		log4erl:info("*** ~p(~4.10.0w)  Failed to login to the ftp server!~s~n",[?MODULE, ?LINE,get_error_reason(Result)]),
% 		Result
% end;
    true ->
      log4erl:info("*** ~p(~4.10.0w) Failed to connect to the ftp server!~s~n", [?MODULE, ?LINE, ftp:formaterror(Pid)]),
%%重连5次
      Num = get_seq(),
      log4erl:info("*** ~p(~4.10.0w)  Num=~p ...~n", [?MODULE, ?LINE, Num]),
      case Num >= 4 of
        true ->
          erase("ftpnum"),
          {Status, Pid};
        false ->
          open(Host, Port, User, Password)
      end
  end.

%% 关闭ftp连接
%% 输入参数：
%%		无。
%% 示例：sxscacc_ftp_client:close()。
close(Pid) ->
  % Pid = get(pid),
  log4erl:info("*** ~p(~4.10.0w) Closing the connection to the ftp server ...~n", [?MODULE, ?LINE]),
  ftp:close(Pid).

%% 上传文件
%% 输入参数：
%%		LocalFile，待上传的本地文件。
%% 备注：文件会被上传到ftp服务器当前工作目录下。
%% 示例：sxscacc_ftp_client:upload("D:/Demo/Erlang/shop0.xml")。
upload(Bin, FileName) ->
  Pid = get(pid),
  {Status, WorkPath} = ftp:pwd(Pid),  %% 获取远程当前工作目录
  if
    Status =:= ok ->
      % FileName = filename:basename(LocalFile),
      RemoteFile = filename:absname(FileName, WorkPath),
      upload(Bin, FileName, RemoteFile);
    true ->
      log4erl:info("*** ~p(~4.10.0w) Failed to return the current working directory at the remote server!~s~n", [?MODULE, ?LINE, ftp:formaterror(WorkPath)]),
      {Status, WorkPath}
  end.

%% 上传文件
%% 输入参数：
%%		Bin，待上传的本地文件;
%%		RemoteFile，待生成的远程文件。
%% 示例：sxscacc_ftp_client:upload("D:/Demo/Erlang/shop0.xml","/Uploaded/shop0.xml")。
upload(Bin, FileName, RemoteFile) ->

  Outcome = ensure_dir(RemoteFile),  %% 确保目标文件的路径存在
  if
    Outcome =:= ok ->
      Pid = get(pid),
      Result = ftp:send_bin(Pid, Bin, RemoteFile),
      if
        Result =:= ok ->
          log4erl:info("*** ~p(~4.10.0w) The file ~p has been uploaded successfully!~n", [?MODULE, ?LINE, FileName]),
          Result;
        true ->
          log4erl:info("*** ~p(~4.10.0w) Failed to upload the file ~p!~s~n", [?MODULE, ?LINE, FileName, get_error_reason(Result)]),
          Result
      end;
    true ->
      log4erl:info("*** ~p(~4.10.0w) Failed to ensure that all parent directories exist!~p.~n", [?MODULE, ?LINE, Outcome]),
      Outcome
  end.

%% 下载文件
%% 输入参数：
%%		RemoteFile，待下载的远程文件。
%% 备注：文件会被下载到本地当前工作目录下。
%% 示例：sxscacc_ftp_client:download("/Uploaded/shop0.xml")。
download(RemoteFile) ->
  {Status, WorkPath} = file:get_cwd(),  %% 获取本地当前路径
  if
    Status =:= ok ->
      FileName = filename:basename(RemoteFile),
      LocalFile = filename:absname(FileName, WorkPath),
      Pid = get(pid),
      download(Pid, RemoteFile, LocalFile);
    true ->
      log4erl:info("*** ~p(~4.10.0w) Failed to return the current working directory of the file server!~p.~n", [?MODULE, ?LINE, file:format_error(WorkPath)]),
      {Status, WorkPath}
  end.

call(GenServer, Msg, Format, Timeout) ->
  Req = {self(), Msg},
  case (catch gen_server:call(GenServer, Req, Timeout)) of
    {ok, Bin} when is_binary(Bin) andalso (Format =:= string) ->
      {ok, binary_to_list(Bin)};
    {'EXIT', _} ->
      {error, eclosed};
    Result ->
      Result
  end.

%% 下载文件
%% 输入参数：
%%		RemoteFile，待下载的远程文件;
%%		LocalFile，待生成的本地文件。
%% 示例：sxscacc_ftp_client:download("/Uploaded/shop0.xml","D:/Demo/Erlang/shop0.xml")。
download(Pid, RemoteFile, LocalFile) ->
  log4erl:info("*** ~p(~4.10.0w)  ftp download start!", [?MODULE, ?LINE]),
  % Existence = is_exist(RemoteFile),
  % log4erl:info("*** ~p(~4.10.0w) DExistenceExistence ~p ...~n",[?MODULE, ?LINE, Existence]),
  % if
  % 	Existence =:= true	->
  Outcome = filelib:ensure_dir(LocalFile),  %% 确保目标文件的路径存在
  if
    Outcome =:= ok ->
      log4erl:info("*** ~p(~4.10.0w) Downloading the remote file ~p to the local file ~p ...~n", [?MODULE, ?LINE, RemoteFile, LocalFile]),
      % Pid = get(pid),
      %ok = ftp:type(Pid, binary),
      %% 1. get file
      ResultNOW = call(Pid, {recv_bin, RemoteFile}, bin, timer:seconds(5)),
      {Result, MessageBin} = case ResultNOW of
                               {ok, <<>>} -> {ok, <<>>};
                               ok -> {ok, <<>>};
                               {ok, _MessageBin} -> {ok, _MessageBin};
                               {error, _} -> log4erl:error("file:~p is not existed!", [RemoteFile]), {error, <<>>} end,
      case MessageBin of
        <<>> ->
          {error, epath};
        _ ->
          file:write_file(LocalFile, MessageBin),
          Result
      end;
  % Result = ftp:recv(Pid,RemoteFile,LocalFile),
  % if
  % 	Result =:= ok	->
  % 		log4erl:info("*** ~p(~4.10.0w) The file ~p has been downloaded successfully!~n",[?MODULE, ?LINE, RemoteFile]),
  % 		Result;
  % 	true	->
  % 		log4erl:info("*** ~p(~4.10.0w) Failed to download the file ~p!~s~n",[?MODULE, ?LINE, RemoteFile, get_error_reason(Result)]),
  % 		Result
  % end;
    true ->
      log4erl:info("*** ~p(~4.10.0w) Failed to ensure that all parent directories exist!~p.~n", [?MODULE, ?LINE, Outcome]),
      Outcome
  end.
% Existence =:= false	->
% 	log4erl:info("*** ~p(~4.10.0w)  The remote file ~p is not exist!~n",[?MODULE, ?LINE, RemoteFile]),
% 	{error, source_not_exist};
% true	->
% 	log4erl:info("*** ~p(~4.10.0w) Can not access the file ~p!~s~n",[?MODULE, ?LINE, RemoteFile, ftp:formaterror(Existence)]),
% 	{error, Existence}
% end.

%% 重命名文件
%% 输入参数：
%%		OldName，原文件;
%%		NewName，新文件。
%% 示例：sxscacc_ftp_client:rename("/Uploaded/shop0.xml","/Uploaded/shop.xml")。
rename(OldName, NewName) ->
  Pid = get(pid),
  Existence = is_exist(OldName),
  if
    Existence =:= true ->
      log4erl:info("*** ~p(~4.10.0w) Renaming the file ~p to ~p at the remote server ...~n", [?MODULE, ?LINE, OldName, NewName]),
      Result = ftp:rename(Pid, OldName, NewName),
      if
        Result =:= ok ->
          log4erl:info("*** ~p(~4.10.0w) The file ~p has been renamed successfully!~n", [?MODULE, ?LINE, OldName]);
        true ->
          log4erl:info("*** ~p(~4.10.0w) Failed to rename the file ~p at the remote server!~s~n", [?MODULE, ?LINE, OldName, get_error_reason(Result)]),
          Result
      end;
    Existence =:= false ->
      log4erl:info("*** ~p(~4.10.0w)  The source file ~p is not exist!~n", [?MODULE, ?LINE, OldName]),
      {error, source_not_exist};
    true ->
      log4erl:info("*** ~p(~4.10.0w) Can not access the file ~p!~s~n", [?MODULE, ?LINE, OldName, ftp:formaterror(Existence)]),
      {error, Existence}
  end.

%% 删除文件
%% 输入参数：
%%		RemoteFile，待删除的远程文件。
%% 示例：sxscacc_ftp_client:delete_file("/Uploaded/shop.xml")。
delete_file(RemoteFile) ->
  Pid = get(pid),
  Existence = is_exist(RemoteFile),
  if
    Existence =:= true ->
      log4erl:info("*** ~p(~4.10.0w) Deleting the file ~p at the remote server ...~n", [?MODULE, ?LINE, RemoteFile]),
      Result = ftp:delete(Pid, RemoteFile),
      if
        Result =:= ok ->
          log4erl:info("*** ~p(~4.10.0w) The file ~p has been deleted successfully!~n", [?MODULE, ?LINE, RemoteFile]);
        true ->
          log4erl:info("*** ~p(~4.10.0w) Failed to delete the file ~p at the remote server!~s~n", [?MODULE, ?LINE, RemoteFile, get_error_reason(Result)]),
          Result
      end;
    Existence =:= false ->
      log4erl:info("*** ~p(~4.10.0w)  The file ~p is not exist!~n", [?MODULE, ?LINE, RemoteFile]),
      {error, source_not_exist};
    true ->
      log4erl:info("*** ~p(~4.10.0w) Can not access the file ~p!~s~n", [?MODULE, ?LINE, RemoteFile, ftp:formaterror(Existence)]),
      {error, Existence}
  end.

%% 删除目录
%% 输入参数：
%%		RemoteDir，待删除的远程目录。
%% 示例：sxscacc_ftp_client:delete_dir("/Uploaded")。
delete_dir(RemoteDir) ->
  Pid = get(pid),
  Existence = is_exist(RemoteDir),
  if
    Existence =:= true ->
      log4erl:info("*** ~p(~4.10.0w) Deleting the directory ~p at the remote server ...~n", [?MODULE, ?LINE, RemoteDir]),
      Result = ftp:rmdir(Pid, RemoteDir),
      if
        Result =:= ok ->
          log4erl:info("*** ~p(~4.10.0w) The directory ~p has been deleted successfully!~n", [?MODULE, ?LINE, RemoteDir]);
        true ->
          log4erl:info("*** ~p(~4.10.0w) Failed to delete the directory ~p at the remote server!~s~n", [?MODULE, ?LINE, RemoteDir, get_error_reason(Result)]),
          Result
      end;
    Existence =:= false ->
      log4erl:info("*** ~p(~4.10.0w)  The directory ~p is not exist!~n", [?MODULE, ?LINE, RemoteDir]),
      {error, source_not_exist};
    true ->
      log4erl:info("*** ~p(~4.10.0w) Can not access the directory ~p!~s~n", [?MODULE, ?LINE, RemoteDir, ftp:formaterror(Existence)]),
      {error, Existence}
  end.

%% 确保远程文件或目录的所有父目录都存在
%% 输入参数：
%%		Remote，远程文件或目录。
%% 示例：sxscacc_ftp_client:ensure_dir("/Uploaded/Recon/20160504/RECON.76.20160503.xml")。
ensure_dir(Remote) ->
  RemotePath = filename:dirname(Remote),
  Pid = get(pid),
  {Status, OldPath} = ftp:pwd(Pid),  %% 记录当前路径
  if
    Status =:= ok ->
      Result = ftp:cd(Pid, RemotePath),
      if
        Result =:= ok ->
          Result;
        true ->
          log4erl:info("*** ~p(~4.10.0w) The directory ~p is not exist!Creating the directory at the remote server ...~n", [?MODULE, ?LINE, RemotePath]),
          PathParts = string:tokens(RemotePath, "/"),
          %% 依次确保每个父目录存在(如果不存在，则建立)
          lists:foldl(fun(Part, _Arg) ->
            Outcome = ftp:cd(Pid, Part),
            if
              Outcome =:= ok ->
                Outcome;
              true ->
                Effect = ftp:mkdir(Pid, Part),
                if
                  Effect =:= ok ->
                    ftp:cd(Pid, Part);
                  true ->
                    log4erl:info("*** ~p(~4.10.0w) Failed to create the directory ~p at the remote server!~s~n", [?MODULE, ?LINE, Part, get_error_reason(Effect)]),
                    Effect
                end
            end
                      end,
            [], PathParts)

      end,
      ftp:cd(Pid, OldPath);  %% 恢复当前路径
    true ->
      log4erl:info("*** ~p(~4.10.0w) Failed to return the current working directory at the remote server!~s~n", [?MODULE, ?LINE, ftp:formaterror(OldPath)]),
      {Status, OldPath}
  end.

%% 枚举ftp目录下的文件，对枚举到的文件的具体处理过程由回调函数Fun定义。
%% 输入参数：
%%		RemotePath，ftp目录；
%%		Recursive，是否对目录RemotePath进行递归匹配查找，如果为 ture 则是，false 则否。
%%		Fun，回调函数，文件名和文件大小作为参数。
%% 示例：
%% enum_files_proc(RemotePath, Recursive, RegExp)	->
%% 	sxscacc_ftp_client:enum_files(RemotePath, Recursive,
%%									fun(File, Size)	->
%% 										case re:run(File, RegExp,[unicode, ucp, caseless]) of
%% 											{match, _Captured}	->
%% 												log4erl:info("*** ~p(~4.10.0w) The size of the file ~p is ~s bytes,backuping ...~n",[?MODULE, ?LINE, File, Size]);
%% 											match	->
%% 												log4erl:info("*** ~p(~4.10.0w) The size of the file ~p is ~s bytes,backuping ...~n",[?MODULE, ?LINE, File, Size]);
%% 											nomatch	->
%% 												log4erl:info("*** ~p(~4.10.0w) Unmatched!Abandoning the file ~p ...~n",[?MODULE, ?LINE, File]);
%% 											{error, ErrType}	->
%% 												log4erl:info("*** ~p(~4.10.0w) Error!~p~n",[?MODULE, ?LINE, ErrType])
%% 										end
%% 									end).
%% 说明：RegExp，正则表达式，第一个字符不能是"*"，否则会报错。
%% 调用：sxscacc_ftp_client:enum_files_proc("/Downloading", true, ".*.xml")。
enum_files(RemotePath, Recursive, Fun) ->
  Pid = get(pid),
  {Status, Text} = ftp:ls(Pid, RemotePath),
  if
    Status =:= ok ->
      LineLists = string:tokens(Text, "\r\n"),
      lists:foldl(fun(Line, _Arg) ->
        {Size, File} = parse_line(Line),
        PathFile = filename:absname(File, RemotePath),
        if
          (Size =:= -1) andalso (Recursive =:= true) ->
            enum_files(PathFile, Recursive, Fun);
          true ->
            Fun(PathFile, Size)
        end
                  end,
        [], LineLists);
    true ->
      log4erl:info("*** ~p(~4.10.0w) Failed to return a list of files at the remote server!~s~n", [?MODULE, ?LINE, ftp:formaterror(Text)]),
      {Status, Text}
  end.

%% 判断远程文件或目录是否存在
%% 输入参数：
%%		Remote，远程文件或目录。
%% 返回：ture，表示存在；false，表示不存在；其它，连接异常或连接没建立，无法确定文件是否存在。
%% 示例：sxscacc_ftp_client:is_exist("/Uploaded/Recon/20160504/RECON.76.20160503.xml")。
is_exist(Remote) ->
  Pid = get(pid),
  log4erl:info("*** ~p(~4.10.0w)  ftp is_exist start pid=~p!", [?MODULE, ?LINE, Pid]),
  Result = ftp:ls(Pid, Remote),
  log4erl:info("*** ~p(~4.10.0w)  ftp is_exist ok Result=~p!", [?MODULE, ?LINE, Result]),
  case Result of
    {_, ok} ->
      true;
    {ok, _} ->
      true;
    ok ->
      true;
    {error, epath} ->
      false;
    {error, Reason} ->
      Reason;
    _ ->
      Result
  end.

%% =============================================================================================================
%% Internal functions
%% =============================================================================================================
%% FTP Server返回信息：
%% UNIX format:
%% drwxrwxrwx   1 owner    group               0 Dec 22  2005 300500
%% drwxrwxrwx   1 owner    group               0 Nov 17  2005 300501
%% drwxrwxrwx   1 owner    group               0 Dec  1  2005 300502
%% -rwxrwxrwx   1 owner    group             178 Nov 17  2005 LOG.TXT
%% -rwxrwxrwx   1 owner    group            7144 Nov 17  2005 MOP.A837.20010904164754
%% -rwxrwxrwx   1 owner    group            7544 Nov 17  2005 MOP.A837.20051117144256
%% -rwxrwxrwx   1 owner    group            8802 Nov 17  2005 MOP.A837.20051202162931
%% DOS format:
%% 12-22-05  03:23PM       <DIR>          300500
%% 11-17-05  04:48PM       <DIR>          300501
%% 12-01-05  04:23PM       <DIR>          300502
%% 11-17-05  04:48PM                  178 LOG.TXT
%% 11-17-05  01:39PM                 7144 MOP.A837.20010904164754
%% 11-17-05  01:49PM                 7544 MOP.A837.20051117144256
%% 11-17-05  04:48PM                 8802 MOP.A837.20051202162931
%% 05-23-16  04:54PM               567974 ftp suite lib.erl
%% 解析文件行
%% 输入参数：
%%		Line，ftp服务器返回的一行，格式见上面FTP Server返回信息。
parse_line(Line) ->
  FirstCh = string:left(Line, 1),
  if
    FirstCh =:= "d" ->    %% unix format dir
      read_file_info(Line, -1, 9);
    FirstCh =:= "-" ->    %% unix format file
      read_file_info(Line, 5, 9);
    true ->        %% Dos
      Pos = string:str(Line, "<DIR>"),
      if
        Pos > 0 ->    %% Dos format dir
          read_file_info(Line, -1, 4);
        true ->    %% Dos format file
          read_file_info(Line, 3, 4)
      end
  end.

%% 提取文件名
%% 考虑到文件命中可能包含空格，所以不能直接从列表中提取，而改为从行字符串中截取。
%% 输入参数：
%%		Line，行信息；
%%		FileSizeElement，列表中表示文件大小的元素(如果是目录传-1)；
%%		FileNameElement，列表中表示文名的元素。
read_file_info(Line, FileSizeElement, FileNameElement) ->
  FileInfoList = string:tokens(Line, " "),
  FilePrefix = lists:nth(FileNameElement, FileInfoList),
  FileStart = string:str(Line, FilePrefix),
  File = string:sub_string(Line, FileStart),

  if
    FileSizeElement =:= -1 ->
      Size = -1;
    true ->
      Size = lists:nth(FileSizeElement, FileInfoList)
  end,

  {Size, File}.

%% 获取错误原因
%% 输入参数：
%%		Result，返回值，格式：{error, Reason}。
get_error_reason(Result) ->
  {error, Reason} = Result,
  ftp:formaterror(Reason).

get_seq() ->
  case get("ftpnum") of
    undefined ->
      put("ftpnum", 1),
      Va = 1;
    _Va ->
      Va = _Va + 1,
      put("ftpnum", Va)
  end,
  Va.

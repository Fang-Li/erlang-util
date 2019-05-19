-module(chatroom).
-behaviour(gen_server).
-export([start_link/0]). % 聊天室启动
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]). % gen_server的行为模式

-define(SERVER, ?MODULE). % 定义聊天室server进程名称,用以注册

% The server state consists of a list of tuples for each person in chat.
% Each tuple has the format {{UserName, UserServer}, PID of person}

% 聊天室服务状态由一个[{}..]的用户列表组成
% 每个tuple为{{UserName, UserServer}, PID of person}的格式存储在stateß

%%% 聊天室启动的便捷方法
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%% gen_server行为模式
init([]) ->
    {ok, []}.

%% Check to see if a user name/server pair is unique;
%% 检测是否用户名称+服务器node是否成对的情况下唯一
%% if so, add it to the server's state
%% 如果唯一,添加到聊天室state内存储
handle_call({login, UserName, ServerRef}, From, State) ->
    {FromPid, _FromTag} = From,
    case lists:keymember({UserName, ServerRef}, 1, State) of
        true ->
            NewState = State,
            Reply = {error, "User " ++ UserName ++ " already in use."};
        false ->
            NewState = [{{UserName, ServerRef}, FromPid} | State],
            Reply = {ok, "Logged in."}
    end,
    {reply, Reply, NewState};

%% Log out the person sending the message, but only
%% 把用户从聊天室内退出
%% if they're logged in already.
handle_call({logout}, From, State) ->
    {FromPid, _FromTag} = From,
    case lists:keymember(FromPid, 2, State) of
        true ->
            NewState = lists:keydelete(FromPid, 2, State),
            Reply = {ok, logged_out};
        false ->
            NewState = State,
            Reply = {error, not_logged_in}
    end,
    {reply, Reply, NewState};

%% When receiving a message from a person, use the From PID to
%% get the user's name and server name from the chatroom server state.
%% Send the message via a "cast" to everyone who is NOT the sender.

%% 当接收到某个用户发送的一条消息,使用该用户的来源PID从聊天室state中获取该用户的名称和来源节点名称,
%% 通过cast发送消息给每个用户,且不包含发送消息的本人

handle_call({say, Text}, From, State) ->
    {FromPid, _FromTag} = From,
    case lists:keymember(FromPid, 2, State) of
        true ->
            {value, {{SenderName, SenderServer}, _}} = lists:keysearch(FromPid, 2, State),
            % For debugging: get the list of recipients.
            RecipientList = [{RecipientName, RecipientServer} ||
                {{RecipientName, RecipientServer}, _} <- State,
                {RecipientName, RecipientServer} /= {SenderName, SenderServer}],
            io:format("Recipient list: ~p~n", [RecipientList]),
            [gen_server:cast({person, RecipientServer}, {message, {SenderName, SenderServer}, Text}) ||
                {{RecipientName, RecipientServer}, _} <- State, RecipientName /= SenderName];
        false ->
            ok
    end,
    {reply, ok, State};

%% Get the state of another person and return it to the asker
%% 用户可以获取他人的个人信息
handle_call({who, _Person, ServerRef}, _From, State) ->
    Reply = gen_server:call({person, ServerRef}, get_profile),
    {reply, Reply, State};

%% Return a list of all users currently in the chat room
%% 获取聊天室内的所有用户
handle_call(users, _From, State) ->
    UserList = [{UserName, UserServer} ||
        {{UserName, UserServer}, _} <- State],
    {reply, UserList, State};

handle_call(Request, _From, State) ->
    {ok, {error, "Unhandled Request", Request}, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(Info, State) ->
    io:format("Received unknown message ~p~n", [Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.




-module(person).
-behaviour(gen_server).
-export([start_link/1]). % 启动的便捷方法,启动用户进程
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]). % gen_server callbacks

-record(state, {chat_node, profile}).

% internal functions
-export([login/1, logout/0, say/1, users/0, who/2, profile/2]).

-define(CLIENT, ?MODULE). % person作为client的注册进程名称

%%% convenience method for startup
start_link(ChatNode) ->
    gen_server:start_link({local, ?CLIENT}, ?MODULE, ChatNode, []).

init(ChatNode)->
    io:format("Chat node is: ~p~n", [ChatNode]),
    {ok, #state{chat_node=ChatNode, profile=[]}}.

%% The server is asked to either:
%% a) return the chat host name from the state,
%% b) return the user profile
%% c) update the user profile

%% client进程作为的服务满足的以下要求:
%% 1. 返回当前client对应的聊天室节点名称
%% 2. 返回当前client内的用户信息
%% 3. 更新用户个人信息


handle_call(get_chat_node, _From, State) ->
    {reply, State#state.chat_node, State};

handle_call(get_profile, _From, State) ->
    {reply, State#state.profile, State};

handle_call({profile, Key, Value}, _From, State) ->
    case lists:keymember(Key, 1, State#state.profile) of
        true -> NewProfile = lists:keyreplace(Key, 1, State#state.profile,
            {Key, Value});
        false ->
            NewProfile = [{Key, Value} | State#state.profile]
    end,
    {reply, NewProfile, #state{chat_node = State#state.chat_node,
        profile=NewProfile}};

handle_call(_, _From, State) -> {ok, [], State}.

handle_cast({message, {FromUser, FromServer}, Text}, State) ->
    io:format("~s (~p) says: ~p~n", [FromUser, FromServer, Text]),
    {noreply, State};

handle_cast(_Request, State) ->
    io:format("Unknown request ~p~n", _Request),
    {noReply, State}.

handle_info(Info, State) ->
    io:format("Received unexpected message: ~p~n", [Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


% internal functions

%% @doc Gets the name of the chat host. This is a really
%% ugly hack; it works by sending itself a call to retrieve
%% the chat node name from the server state.

%% 内部未导出的工具函数
%% 用户向客户端进程本身发送一个call,来获取聊天室服务的node名称

get_chat_node() ->
    gen_server:call(person, get_chat_node).

%% @doc Login to a server using a name
%% If you connect, tell the server your user name and node.
%% You don't need a reply from the server for this.

%% 以UserName的名称登录进入聊天室
%% 连接上聊天室进程的时候,告诉聊天室你的身份
%% 不需要服务器回复什么消息

-spec(login(string()) -> term()).
login(UserName) ->
    ChatNode = get_chat_node(),
    if
        is_atom(UserName) ->
            gen_server:call({chatroom, ChatNode},
                {login, atom_to_list(UserName), node()});
        is_list(UserName) ->
            gen_server:call({chatroom, ChatNode},
                {login, UserName, node()});
        true ->
            {error, "User name must be an atom or a list"}
    end.


%% @doc Log out of the system. The person server will send a From that tells
%% who is logging out; the chatroom server doesn't need to reply.

%% 退出聊天室,用户进程会发送到聊天室一条消息,声明我退出了,聊天室会将该用户,从聊天室内除名

-spec(logout() -> atom()).
logout() ->
    ChatNode = get_chat_node(),
    gen_server:call({chatroom, ChatNode}, {logout}),
    ok.


%% @doc Send the given Text to the chat room server. No reply needed.

%% 用户登录成功后, 可以在聊天室内说话

-spec(say(string()) -> atom()).
say(Text) ->
    ChatNode = get_chat_node(),
    gen_server:call({chatroom, ChatNode}, {say, Text}),
    ok.


%% @doc Ask chat room server for a list of users.

%% 聊天室内用户列表
-spec(users() -> [string()]).
users() ->
    gen_server:call({chatroom, get_chat_node()}, users).


%% @doc Ask chat room server for a profile of a given person.
%% 向聊天室查询某个成员的个人信息

-spec(who(string(), atom()) -> [tuple()]).
who(Person, ServerRef) ->
    gen_server:call({chatroom, get_chat_node()}, {who, Person, ServerRef}).

%% @doc Update profile with a key/value pair.
%% 更新聊天室内成员个人信息

-spec(profile(atom(), term()) -> term()).
profile(Key, Value) ->
    % ask *this* server for the current state
    NewProfile = gen_server:call(person, {profile, Key, Value}),
    {ok, NewProfile}.






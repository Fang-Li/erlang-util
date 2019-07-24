%%%-------------------------------------------------------------------
%%% @author lifang
%%% @copyright (C) 2019, <Wish Start>
%%% @doc
%%%
%%% @end
%%% Created : 28. Jun 2019 5:31 PM
%%%-------------------------------------------------------------------
-module(hot_reload).
-author("lifang").

-export([link_with/1, message_receiver/0]).

link_with(ClientPid) ->
    process_flag(trap_exit, true),
    register(client, ClientPid),
    spawn_link(hot_reload, message_receiver, []).

message_receiver() ->
    receive
        {price, Item} ->
            reply_with_price_of(Item),
            message_receiver();
        Error ->
            reply_with_price_of(Error),
            message_receiver()
    end.

reply_with_price_of(Item) ->
    client ! io:format("The price of ~p is: $~p ~n", [Item, price(Item)]).

price(Item) ->
    case Item of
        tea -> 2.05;
        coffee -> 2.10;
        milk -> 0.9;
        bread -> 0.50;
        _ -> Item
    end.


% 1> c(hot_reload).
% {ok,hot_reload}
% 2> Service = hot_reload:link_with(self()).
% <0.37.0>
% 3> Service ! {price, milk}.
% The price of milk is: $0.99
% {price,milk}

% erlang:unregister(client).
% code:purge(hot_reload).
% code:soft_purge(hot_reload).
% code:load_file(hot_reload).


% -export([link_with/1, message_receiver/0, reply_with_price_of/1]).
%
% ...
% message_receiver() ->
%     receive
%         {price, Item} ->
%             hot_reload:reply_with_price_of(Item),
%             hot_reload:message_receiver()
%     end.
% ...


% 4> c(hot_reload).
% {ok,hot_reload}
% 5> Service ! {price, milk}.
% The price of milk is: $1.03
% {price,milk}
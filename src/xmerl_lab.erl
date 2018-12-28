%%%-------------------------------------------------------------------
%%% @author lifang
%%% @copyright (C) 2018, <Wish Start>
%%% @doc
%%%
%%% @end
%%% Created : 28. Dec 2018 1:51 PM
%%%-------------------------------------------------------------------
-module(xmerl_lab).
-author("lifang").
-compile(export_all).

-include_lib("xmerl/include/xmerl.hrl").

%% @doc Helper function to generate XML from a data structure and print it
serialize(Data) ->
    Xml = lists:flatten(xmerl:export_simple(Data, xmerl_xml)),
    io:format("~s~n", [Xml]).

serialize_comment(Data) ->
    Xml = lists:flatten(xmerl:export(Data, xmerl_xml)),
    io:format("~s~n", [Xml]).

%% @doc Prints <?xml version="1.0"?><cheese type="soft" produced="2013-02-21T12:57:00"/>
test1() ->
    serialize([{cheese,
        [{type, "soft"},
            {produced, "2013-02-21T12:57:00"}],
        []}]).

%% @doc Prints <?xml version="1.0"?><cheeses>yarg</cheeses>
test2() ->
    serialize([#xmlElement{name = cheeses, content = [#xmlText{value = "yarg"}]}]).

%% @doc Prints <?xml version="1.0"?><cheeses><cheese>yarg</cheese><cheese>parmesan</cheese><cheese>cheddar</cheese></cheeses>
%% xmerl simple encoding requires element content to be a list.
%% You may get an error like "no function clause matching
%% xmerl_lib:expand_content".
%% Good: {cheese, ["yarg"]}
%% Bad: {cheese, "yarg"}
test3() ->
    RootElem = {cheeses, [{cheese, ["yarg"]}, {cheese, ["parmesan"]}, {cheese, ["cheddar"]}]},
    serialize([RootElem]).

%% @doc Prints <?xml version="1.0"?><cheeses xmlns="http://cheese.com/">yarg</cheeses>
test4() ->
    Ns = "http://cheese.com/",
    RootElem = #xmlElement{name = cheeses,
        namespace = #xmlNamespace{default = Ns},
        attributes = [#xmlAttribute{name = xmlns, value = Ns}],
        content = [#xmlText{value = "yarg"}]},
    serialize([RootElem]).

%% @doc Prints <?xml version="1.0"?><cheeses xmlns="http://cheese.com/names"><cheese><yarg><type>medium</type><country>nl</country></yarg></cheese></cheeses>
test5() ->
    Ns1 = "http://cheese.com/names",
    RootElem = #xmlElement{name = cheeses,
        namespace = #xmlNamespace{default = Ns1},
        attributes = [#xmlAttribute{name = xmlns, value = Ns1}],
        content = [{cheese, [{yarg, [{type, ["medium"]},
            #xmlElement{name = country,
                content = ["nl"]}]}]}]},
    serialize([RootElem]).

%% @doc Prints <?xml version="1.0"?><cheeses xmlns="http://cheese.com/names" xmlns:c="http://cheese.com/countries"><cheese><yarg><type>medium</type><c:country>nl</c:country></yarg></cheese></cheeses>
%% You can get xmerl to export documents with multiple namespaces, but it's
%% pretty manual, using the namespace slots in the various record types didn't
%% alter the output when tested.
test6() ->
    Ns1 = "http://cheese.com/names",
    Ns2 = "http://cheese.com/countries",
    RootElem = {cheeses,
        [{xmlns, Ns1}, {'xmlns:c', Ns2}],
        [{cheese, [{yarg, [{type, ["medium"]}, {'c:country', ["nl"]}]}]}]},
    serialize([RootElem]).

test7() ->
    Ns = "http://cheese.com/",
    RootElem = #xmlElement{name = cheeses,
        namespace = #xmlNamespace{default = Ns},
        attributes = [#xmlAttribute{name = xmlns, value = Ns}],
        content = [
            #xmlComment{
                parents = [2],  % [{atom(),integer()}]
                pos = 3,             % integer()
                language = [],  % inherits the element's language
                value = <<"nihao">>
            },
            #xmlText{value = "yarg"}]},
    serialize_comment([RootElem]).


test8() ->
    serialize([{cheese,
        [{type, "soft"},
            {produced, "2013-02-21T12:57:00"}],
        []},
        {comment, [{aa, <<"hhhh">>}], []}]).

%% formatter xml
%% TODO
test9() ->
    Data =
        {bike,
            [{year, "2003"}, {color, "black"}, {condition, "new"}],
            [{name,
                [{manufacturer, ["Harley Davidsson"]},
                    {brandName, ["XL1200C"]},
                    {additionalName, ["Sportster"]}]},
                {engine,
                    ["V-engine, 2-cylinders, 1200 cc"]},
                {kind, ["custom"]},
                {drive, ["belt"]}]},
    {RootEl,Misc}=xmerl_scan:file('motorcycles.xml'),
    #xmlElement{content=Content} = RootEl,
    NewContent=Content++lists:flatten([Data]),
    NewRootEl=RootEl#xmlElement{content=NewContent}.

%% http://erlang.org/doc/apps/xmerl/xmerl_ug.html
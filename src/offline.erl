-module(offline).
-compile(export_all).

-record(jid,{user,domain,resource,luser,ldomain,lresource}).
-record(xmlelement,{name,attrs,children}).
-record(xmlcdata,{cdata}).


%%  逻辑层
make_offline(super_groupchat,{SuperGroupchat,From,To,Packet},{Idlist,MsgId}) ->
  ok.

make_body({From,To,Packet,SuperGroupchat}) ->
  % io:format("make_body .. 1 ~p~n",[From]),
  % io:format("make_body .. 2 ~p~n",[SuperGroupchat]),
  KeyRes = lists:keyfind(From,1,SuperGroupchat),
  % io:format("make_body .. 3 ~p~n",[KeyRes]),
  case KeyRes of 
    false ->
      #xmlelement{attrs=Attr,children=Children} = Packet,
      #xmlelement{children=Children2} = Children,
      [#xmlcdata{cdata=CData}]=Children2,
      Msgtime=proplists:get_value("msgTime",Attr),
      {ok,JO,_} = rfc4627:decode(CData),
      {obj,Proplist}=JO,
      Userid=rfc4627:get_field(JO,"userid"),
      Id=rfc4627:get_field(JO,"id"),
      JB = rfc4627:encode(JO),
      NewPacket = {xmlelement,"message",Attr,[{xmlelement,"body",[],[{xmlcdata,list_to_binary(JB)}]}]},
      OfflineZipKey = atom_to_list(Id) ++"/zip_offline_msg_body",
      {[{From,To,SuperGroupchat}|[]],[{OfflineZipKey}]};
    _ -> 
      other
  end.
      
  
  

  

  
  
args()->
  super().
  
  
%% 数据层
jo() ->
  {obj,[{"userid",<<"15538">>},
          {"username",<<"Jim">>},
          {"userimage",
           <<"http://beta.iyueni.com/Uploads/avatar/2/15538_pgL9AK.jpg_200_200_2_80.jpg">>},
          {"usergender",1},
          {"type",0},
          {"content",
           <<230,137,173,230,137,173,230,141,143,230,141,143>>},
          {"msgsource",<<231,186,166,228,189,160>>},
          {"msgtype",<<"0">>}]}.

packet(JO)->
  Jsonbin= list_to_binary(rfc4627:encode(JO)),
  Packet = {xmlelement,"message",[{from,"1680028@yiqibo.tv"}],{xmlelement,"body",[],[#xmlcdata{cdata=Jsonbin}]}}.
  
super() ->
  From = {jid,"1680028","yiqibo.tv","","1680028","yiqibo.tv",""},
  To = {jid,"1680028","yiqibo.tv","","1680028","yiqibo.tv",""},
  Packet=packet(jo()),
  SuperGroupchat=[{from,to,xmlelement},{"",To,Packet}],
  {From,To,Packet,SuperGroupchat}.
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
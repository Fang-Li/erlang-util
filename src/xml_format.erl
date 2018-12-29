%% coding: latin-1
-module(xml_format).
-author('1yanan.zhang@ergchina.com').
%-include_lib("xmerl/include/xmerl.hrl").
-include_lib("xmerl/include/xmerl.hrl").
-define(SEQFILE, "/afc/app/src/mlcMQBridgeServer/priv/seq.txt"). %%  存放序列
-define(RSA_PUBLIC_KEY, <<"-----BEGIN PUBLIC KEY-----\r\nXXXRSA_PUBLIC_KEYXXX\r\n-----END PUBLIC KEY-----">>).
-define(RSA_PRIVATE_KEY, <<"-----BEGIN RSA PRIVATE KEY-----\r\nXXXRSA_PRIVATE_KEYXXX\r\n-----END RSA PRIVATE KEY-----">>).

-define(xml_prolog, "<!--枚举黑名单-->").
-compile(export_all).
-define(DirPath, "E:/开发/").

%% BCD串转HEX串
%% 输入参数：
%%    BCDString,  BCD数据；
%%    Size,   BCD数据长度；
%%    Acc,    累积器。
%% 返回：
%%    HEX串。
%% 示例：
%%    bcd_to_hex("201",6,[]).

bcd_to_hex(BCDString, BytesSize, Acc) ->
    String = string:right(BCDString, 2 * BytesSize, $0),
    bcd_to_hex(String, Acc).

%% BCD串转HEX串
%% 输入参数：
%%    BCDString,  BCD数据；
%%    Acc,    累积器。
%% 返回：
%%    HEX串。
%% 示例：
%%    bcd_to_hex("201608102D3CE12F",[]).
bcd_to_hex(BCDString, Acc) ->
    Length = string:len(BCDString),
    Rem = Length rem 2,
    String = if
                 Rem =:= 0 ->
                     BCDString;
                 true ->
                     string:right(BCDString, Length + 1, $0)
             end,

    {Selected, Remainder} = lists:split(2, String),
    Int = list_to_integer(Selected, 16),
    List = lists:append(Acc, [Int]),
    RemainderLen = length(Remainder),
    if
        RemainderLen > 0 ->
            bcd_to_hex(Remainder, List);
        true ->
            List
    end.



queryBlacklist() ->
    %BlackList+版本号（yyyymmdd+4位流水号）.xml
    Date = get_localdate(),
    FileName = "BlackList" ++ Date ++ getNumber() ++ ".xml",
    GetBlacklist = "1,2,3,4,5",
    [Version1, CardPlanId, CardPlanName, SignatureType, SignatureData] = string:tokens(GetBlacklist, ","),
    GetPrice1 = ["1,2,3,4,5,6,7,8,9,10,1,2", "11,12,13,14,15,16,17,18,19,10,11,12", "1,2,3,4,5,6,7,8,9,10,1,2", "11,12,13,14,15,16,17,18,19,10,11,12"],
    Version = {version, [{version, Version1}], []},
    _CardTypeInfo = lists:map(fun(L) ->
        [_CardType, CardTypeEx, CardTypeName, CardTypeName_En, Description, ForeGift, Charge, DateAvailable, CardValue, MediaType, Curvalue, CardAttrib] = string:tokens(L, ","),
        {'CardTypeInfo', [{'CardType', _CardType}, {'CardTypeEx', CardTypeEx}, {'CardTypeName', CardTypeName}, {'CardTypeName_En', CardTypeName_En}, {'Description', Description},
            {'ForeGift', ForeGift}, {'Charge', Charge}, {'DateAvailable', DateAvailable}, {'CardValue', CardValue}, {'MediaType', MediaType}, {'Curvalue', Curvalue}, {'CardAttrib', CardAttrib}], []}
                              end,
        GetPrice1),

    CardType11 = {'CardType', [], _CardTypeInfo},

    %%%%%运营点矩阵
    GetPrice2 = ["1,2"],
    StationInfo = lists:map(fun(L) ->
        [Length, Content] = string:tokens(L, ","),
        {'StationInfo', [{'Length', Length}, {'Content', Content}], []}
                            end,
        GetPrice2),
%%%%%每个标记下存储一个基本价格信息
    GetPrice3 = ["w,qwq,5,6", "w2ds,qwq,ddd,dsss", "ttt,dfd,twdsadv,qwq", "333,222,wdsad,qwq"],
    _BasicPlanInfo = lists:map(fun(L) ->
        [BasicPlanNo, BasicPlanName, BasicRule, Divide] = string:tokens(L, ","),
        {'BasicPlanInfo', [{'BasicPlanNo', BasicPlanNo}, {'BasicPlanName', BasicPlanName}, {'BasicRule', BasicRule}, {'Divide', Divide}], []}
                               end,
        GetPrice3),
    BasicFare = {'BasicFare', [], _BasicPlanInfo},
%%%%%每个标记下存储一个计费规则
    GetPrice4 = ["321,123,222", "321,123,222", "321,123,222", "321,123,222", "321,123,222", "321,123,222", "321,123,222", "321,123,222", "321,123,222"],
    _FareRulePlanInfo = lists:map(fun(L) ->
        [PlanId, PlanName, PlanProperty] = string:tokens(L, ","),
        {'FareRulePlanInfo', [{'PlanId', PlanId}, {'PlanName', PlanName}, {'PlanProperty', PlanProperty}], []}
                                  end,
        GetPrice4),
    FareRulePlan = {'FareRulePlan', [], _FareRulePlanInfo},
%%%%%每个标记下存储一个卡方案
    GetPrice5 = ["w,qwq,5,6", "w2ds,qwq,ddd,dsss", "ttt,dfd,twdsadv,qwq", "333,222,wdsad,qwq", "333,222,wdsad,qwq"],
    _CardPlanList = lists:map(fun(L) ->
        [CardType1, CardTypeEx1, FareRulePlan1, BasicPlanNo] = string:tokens(L, ","),
        {'CardPlanList', [{'CardType', CardType1}, {'CardTypeEx', CardTypeEx1}, {'FareRulePlan', FareRulePlan1}, {'BasicPlanNo', BasicPlanNo}], []}
                              end,
        GetPrice5),
    _CardPlanInfo = {'CardPlanInfo', [{'CardPlanId', CardPlanId}, {'CardPlanName', CardPlanName}], _CardPlanList},
    CardPlan = {'cardPlan', [], [_CardPlanInfo]},
    _RuleInfo = {'RuleInfo', [], []},
    ContinuousRule = {'ContinuousRule', [], [_RuleInfo]},
%%%%%每个标记下存储一个计价方案信息
    GetPrice6 = ["w,qwq,5,6,5", "w2ds,qwq,ddd,5,dsss", "ttt,dfd,6,twdsadv,qwq", "333,6,222,wdsad,qwq", "35,6,222,wdsad,qwq"],
    _FarePlanInfo = lists:map(fun(L) ->
        [FarePlanNo, FarePlanName, CardPlanNo, ContinuousRule1, IfDefault] = string:tokens(L, ","),
        {'FarePlanInfo', [{'FarePlanNo', FarePlanNo}, {'FarePlanName', FarePlanName}, {'CardPlanNo', CardPlanNo}, {'ContinuousRule', ContinuousRule1}, {'IfDefault', IfDefault}], []}
                              end,
        GetPrice6),
    FarePlan = {'FarePlan', [], _FarePlanInfo},

    Signature = {'Signature', [{'SignatureType', SignatureType}, {'SignatureData', SignatureData}], []},
    A = [Version, CardType11] ++ StationInfo ++ [BasicFare, FareRulePlan, CardPlan, ContinuousRule, FarePlan, Signature],
    NewContent = xmerl:export_simple([{'Price', [], A}], xmerl_xml),
    file:write_file(FileName, NewContent).

queryStation() ->
    %BlackList+版本号（yyyymmdd+4位流水号）.xml
    Date = get_localdate(),
    FileName = "BlackList" ++ Date ++ getNumber() ++ ".xml",
    GetBlacklist = "1,2,3",

    [Version1, SignatureType, SignatureData] = string:tokens(GetBlacklist, ","),
    Version = {version, [{version, Version1}], []},
    GetStation2 = ["1,天通苑", "2,回龙观"],
    _BasicInfo = lists:map(fun(L) ->
        [Id, Name] = string:tokens(L, ","),
        GetStation1 = ["22222,wwwwwww", "33333333,ffffffffff", "44444444,rrrrrrr"],
        _StationList = lists:map(fun(L1) ->
            [FareStationId, SortId] = string:tokens(L1, ","),
            {'StationList', [{'FareStationId', FareStationId}, {'SortId', SortId}], []}
                                 end,
            GetStation1),
        {'BasicInfo', [{'Id', Id}, {'Name', Name}], _StationList}
                           end,
        GetStation2),
    LineBaseInfo = {'LineBaseInfo', [], _BasicInfo},
%%%%车站信息
    GetStation3 = ["1,2,3,4,5", "6,7,8,9,10", "1,2,3,4,5"],
    _BasicInfo1 = lists:map(fun(L) ->
        [FareStationId2, StationId, StationName, StationName_En, ExchgStationId] = string:tokens(L, ","),
        {'BasicInfo', [{'FareStationId', FareStationId2}, {'StationId', StationId}, {'StationName', StationName}, {'StationName_En', StationName_En}, {'ExchgStationId', ExchgStationId}], []}
                            end,
        GetStation3),
    StationInfo = {'StationInfo', [], _BasicInfo1},
%%%%%区段信息
    GetStation4 = ["3,天安门", "4,东单"],
    _BasicInfo2 = lists:map(fun(L2) ->
        [Id1, Name1] = string:tokens(L2, ","),
        GetStation5 = ["22222,wwwwwww", "33333333,ffffffffff", "44444444,rrrrrrr"],
        _StationList1 = lists:map(fun(L3) ->
            [FareStationId3, SortId1] = string:tokens(L3, ","),
            {'StationList', [{'FareStationId', FareStationId3}, {'SortId', SortId1}], []}
                                  end,
            GetStation5),
        {'BasicInfo', [{'Id', Id1}, {'Name', Name1}], _StationList1}
                            end,
        GetStation4),
    AreaBaseInfo = {'AreaBaseInfo', [], _BasicInfo2},

    Signature = {'Signature', [{'SignatureType', SignatureType}, {'SignatureData', SignatureData}], []},
    A = [Version, LineBaseInfo, StationInfo, AreaBaseInfo, Signature],
    NewContent = xmerl:export_simple([{'Station', [], A}], xmerl_xml),
    file:write_file(FileName, NewContent).

queryOperationTime() ->
    %BlackList+版本号（yyyymmdd+4位流水号）.xml
    Date = get_localdate(),
    FileName = "BlackList" ++ Date ++ getNumber() ++ ".xml",
    GetOperationTime = "1,2,3,4,5,6,7",

    [Version1, Time, OpenTime, LineId, CloseTime, SignatureType, SignatureData] = string:tokens(GetOperationTime, ","),
    Version = {'Version', [{'Version', Version1}], []},
    Transform_Time = {'Transform_Time', [{'Time', Time}], []},
    OperationTime = {'OperationTime', [{'OpenTime', OpenTime}, {'LineId', LineId}, {'CloseTime', CloseTime}], []},
    Signature = {'Signature', [{'SignatureType', SignatureType}, {'SignatureData', SignatureData}], []},
    A = [Version, Transform_Time, OperationTime, Signature],
    NewContent = xmerl:export_simple([{'OperationTime', [], A}], xmerl_xml),
    file:write_file(FileName, NewContent).

queryOperationControl() ->
    %BlackList+版本号（yyyymmdd+4位流水号）.xml
    Date = get_localdate(),
    FileName = "priv/BlackList" ++ Date ++ getNumber() ++ ".xml",
    GetBlacklist = "1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8",

    [Version1, EmergencyModeExtendTime, BreakdownModeExtendTime, CheckFreeModeExtendTime, ResidenceTime, OpenTime, CloseTime,
        WaitForPass, CardTypeForAGM, MaxDisplayNum, MaxCoinGiveChange, CustomerOperationTime, CardTypeForTVM, MaxUpdateTimes, CardTypeForBOM, GroupTickePriceOffValue
        , Drawback, ProlongTime, OrderErrorUpdate, OverTimeUpdate, BlackListUnlock, PoundageforTheLoss, PoundageforTheFind, TicketForOut, DepreciationCost,
        DrawbackAfterLoss, SignatureType, SignatureData] = string:tokens(GetBlacklist, ","),


    %% 格式化xml的换行符定义
    Enter = #xmlText{value = "\
"},
    %% 二级: 四个空格
    Enter2 = #xmlText{value = "\
    "},
    %% 三级: 八个空格
    Enter3 = #xmlText{value = "\
        "},

    %% 空格: 二级
    Space2 = #xmlText{value = "        "},
%%%%通用运营控制参数
    GetOperationControl1 = ["1,2", "2,3", "3,4"],
    _TradeType = lists:foldl(
        fun(L, Acc) ->
            [Coding, Content] = string:tokens(L, ","),
            [{'TradeType', [{'Coding', Coding}, {'Content', Content}], []}, Enter3 | Acc]
        end, [], GetOperationControl1),
    GetOperationControl2 = ["eee,2", "eeee,3", "eeeeee,4"],
    _CardStatus = lists:foldl(
        fun(L, Acc) ->
            [Coding1, Content1] = string:tokens(L, ","),
            [{'CardStatus', [{'Coding', Coding1}, {'Content', Content1}], []}, Enter3 | Acc]
        end, [], GetOperationControl2),
    W = [Space2] ++ _TradeType ++ lists:droplast(_CardStatus) ++ [Enter2],

    %% 所有待格式化的内容
    Version =
        {version,
            [
                {version, Version1}
            ], []},
    CommonParam =
        {'CommonParam',
            [
                {'EmergencyModeExtendTime', EmergencyModeExtendTime},
                {'BreakdownModeExtendTime', BreakdownModeExtendTime},
                {'CheckFreeModeExtendTime', CheckFreeModeExtendTime},
                {'ResidenceTime', ResidenceTime},
                {'OpenTime', OpenTime},
                {'CloseTime', CloseTime}
            ], [Enter] ++ W},

    AGMParam =
        {'AGMParam',
            [
                {'WaitForPass', WaitForPass},
                {'CardTypeForAGM', CardTypeForAGM}
            ], []},
    TVMParam =
        {'TVMParam',
            [
                {'MaxDisplayNum', MaxDisplayNum},
                {'MaxCoinGiveChange', MaxCoinGiveChange},
                {'CustomerOperationTime', CustomerOperationTime},
                {'CardTypeForTVM', CardTypeForTVM}
            ], []},
    BOMParam =
        {'BOMParam',
            [
                {'MaxUpdateTimes', MaxUpdateTimes},
                {'CardTypeForBOM', CardTypeForBOM},
                {'GroupTickePriceOffValue', GroupTickePriceOffValue}
            ], []},
    PoundageParam =
        {'PoundageParam',
            [{'Drawback', Drawback},
                {'ProlongTime', ProlongTime},
                {'OrderErrorUpdate', OrderErrorUpdate},
                {'OverTimeUpdate', OverTimeUpdate},
                {'BlackListUnlock', BlackListUnlock},
                {'PoundageforTheLoss', PoundageforTheLoss},
                {'PoundageforTheFind', PoundageforTheFind},
                {'TicketForOut', TicketForOut},
                {'DepreciationCost', DepreciationCost},
                {'DrawbackAfterLoss', DrawbackAfterLoss}
            ], []},
    Signature =
        {'Signature',
            [
                {'SignatureType', SignatureType},
                {'SignatureData', SignatureData}
            ], []},
    Data = [Enter2, Version, Enter2, CommonParam, Enter2, AGMParam, Enter2, TVMParam, Enter2, BOMParam, Enter2, PoundageParam, Enter2, Signature, Enter],
    NewContent = xmerl:export_simple([Enter, {'OperationControl', [], Data}], xmerl_xml),
    file:write_file(FileName, NewContent).

queryStationMap() ->
    %BlackList+版本号（yyyymmdd+4位流水号）.xml
    Date = get_localdate(),
    FileName = "BlackList" ++ Date ++ getNumber() ++ ".xml",
    GetBlacklist = "1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10,1",

    [VersionId, VersionDate, VersionType, VersionValidate, VersionSystem, VersionOper, FormatVersion,
        ResolutionId, Content, ImageName, StationCount, StationId, IsUse, X, Y, W, H, Rx, Ry,
        LineId, ImageName1, IsUse1, StationCount1, StationId2, IsUse2, X1, Y1, W1, H1, Rx1, Ry1] = string:tokens(GetBlacklist, ","),
    Version = {'Version', [{'VersionId', VersionId}, {'VersionDate', VersionDate}, {'VersionType', VersionType}, {'VersionValidate', VersionValidate},
        {'VersionSystem', VersionSystem}, {'VersionOper', VersionOper}, {'FormatVersion', FormatVersion}], []},

    _StationInfo = {'StationInfo', [{'StationId', StationId}, {'IsUse', IsUse}, {'X', X}, {'Y', Y}, {'W', W}, {'H', H}, {'Rx', Rx}, {'Ry', Ry}], []},
    GlobalInfo = {'GlobalInfo', [{'ImageName', ImageName}, {'StationCount', StationCount}], [_StationInfo]},

    _StationInfo1 = {'StationInfo', [{'StationId', StationId2}, {'IsUse', IsUse2}, {'X', X1}, {'Y', Y1}, {'W', W1}, {'H', H1}, {'Rx', Rx1}, {'Ry', Ry1}], []},
    _MapInfo = {'MapInfo', [{'LineId', LineId}, {'ImageName', ImageName1}, {'IsUse', IsUse1}, {'StationCount', StationCount1}], [_StationInfo1]},
    LineInfo = {'LineInfo ', [], [_MapInfo]},
    ResolutionInfo = {'ResolutionInfo ', [{'ResolutionId', ResolutionId}, {'Content', Content}], [GlobalInfo, LineInfo]},

    A = [Version, ResolutionInfo],
    NewContent = xmerl:export_simple([{'ModeResumeParam', [], A}], xmerl_xml, [{Version, ?xml_prolog}]),
    file:write_file(FileName, NewContent).

queryModeResumeParam() ->
    %%<!--版本信息-->
    %BlackList+版本号（yyyymmdd+4位流水号）.xml
    Date = get_localdate(),
    FileName = "BlackList" ++ Date ++ getNumber() ++ ".xml",
    GetBlacklist = "1,2,3,4,5,6,7",
    [VersionId, VersionDate, VersionType, VersionValidate, VersionSystem, VersionOper, FormatVersion
    ] = string:tokens(GetBlacklist, ","),
    Version = {'Version', [{'VersionId', VersionId}, {'VersionDate', VersionDate}, {'VersionType', VersionType}, {'VersionValidate', VersionValidate},
        {'VersionSystem', VersionSystem}, {'VersionOper', VersionOper}, {'FormatVersion', FormatVersion}], []},
%%%%模式履历参数
    GetModeResumeParam1 = [["1", "2", "3", "4"], ["6", "7", "8", "9"], ["1", "3", "4", "5"]],
    ModeResume = lists:map(fun(L) ->
        [StationID, StationMode, ModeStartTime, ModeEndTime] = L,
        {'ModeResume', [{'StationID', StationID}, {'StationMode', StationMode}, {'ModeStartTime', ModeStartTime}, {'ModeEndTime', ModeEndTime}], []}
                           end,
        GetModeResumeParam1),
    AA = {'!--版本信息--', [], []},
    A = [Version, AA] ++ ModeResume,

    io:format(" AAA =========~p  ~n", [A]),
    NewContent = xmerl:export_simple([{'ModeResumeParam', [], A}], xmerl_xml),
    file:write_file(FileName, NewContent).
create_xml() ->
    Date = get_localdate(),
    FileName = "BlackList" ++ Date ++ getNumber() ++ ".xml",
    ShoppingList = "1.1,20181126144700,123,\n,100,2,1",
    Items = lists:map(fun(L) ->
        [Name, Quantity, Price] = string:tokens(L, ","),
        {item, [{name, Name}, {quantity, Quantity}, {price, Price}], []}
                      end,
        string:tokens(ShoppingList, "\n")),
    NewContent = xmerl:export_simple([{shopping, [], Items}], xmerl_xml),
    io:format(" FileName =========~p  ~n", [FileName]),
    file:write_file(FileName, NewContent).

get_localdate() ->
    {{Y, M1, D1}, {_, _, _}} = calendar:local_time(),
    M = lists:flatten(io_lib:format("~2.10.0B", [M1])),
    D = lists:flatten(io_lib:format("~2.10.0B", [D1])),
    integer_to_list(Y) ++ M ++ D.

split_LO() ->
    Filename = "L180000003000000012018112601.txt",
%%读取文件第一行File Description Area

    {ok, File} = file:open(Filename, [read]),
    {ok, _Version} = file:read_line(File),
    Version = string:tokens(_Version, "\n \t"),

%%读取文件第二行Transaction Header
    {ok, _Header} = file:read_line(File),
    HeadList = string:tokens(_Header, "\n \t"),
%%例子["2018112680000003","1","0"]

%%读取文件Transaction data
    DATA = read_txt(File, []),

    file:close(File),
    Len = length(DATA),

    F = fun(_E, {BinData, OutList}) ->
        case (BinData == []) of
            true ->
                {BinData, OutList};
            false ->
                [TXTDATE | H] = BinData,
                AA = Version ++ HeadList ++ TXTDATE,
                io:format(" 1 =========~p  ~n", [AA]),
                {H, OutList ++ [AA]}
        end
        end,
    A = lists:foldl(F, {DATA, []}, lists:seq(1, Len)),
    io:format(" AAAAAAA =========~p  ~n", [A]).
read_txt(File, OUT) ->

    case file:read_line(File) of
        eof -> OUT;
        {ok, VALUE} ->

            Value = string:tokens(VALUE, "\n \t"),
            read_txt(File, OUT ++ [Value])
    end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%MD5加密
md5(S) ->
    S1 = term_to_binary(S),
    Md5_bin = erlang:md5(S1),
    Md5_list = binary_to_list(Md5_bin),
    lists:flatten(list_to_hex(Md5_list)).

list_to_hex(L) ->
    lists:map(fun(X) -> int_to_hex(X) end, L).

int_to_hex(N) when N < 256 ->
    A = [hex(N div 16), hex(N rem 16)],
    io:format(" AAAAAAA =========~p  ~n", [A]).


hex(N) when N < 10 ->
    $0 + N;
hex(N) when N >= 10, N < 16 ->
    $a + (N - 10).
start() ->
    {ok, Type} = file:read_file("BlackList201812280004.xml"),
    NewContent = re:replace(Type, "--/>", "-->", [global, {return, list}]),
    file:write_file("BlackList201812280009.xml", NewContent).





txt() ->
    ShoppingList = ["1,2,3", "1,2,3"],
    Items = lists:map(fun(L) ->
        [Name, Quantity, Price] = string:tokens(L, ","),
        {item, [{name, Name}, {quantity, Quantity}, {price, Price}], []}
                      end,
        ShoppingList),
    io:format(" Items =========~p  ~n", [Items]),
    xmerl:export_simple([{shopping, [], Items}], xmerl_xml).
getNumber() ->
    _Serial_number =
        case get(getNumber) of
            undefined ->
                put(getNumber, 1),
                1;
            _Seq ->
                case _Seq > 9999 of
                    true ->
                        put(getNumber, 1),
                        1;
                    _ ->
                        put(getNumber, _Seq + 1),
                        _Seq + 1
                end
        end,

    string:right(integer_to_list(_Serial_number), 4, $0).


%%https://blog.csdn.net/flyinmind/article/details/17394205
%%产生RSA签名	
%-spec gen_rsa_sign(MsgBin, DigestType, KeyBin) -> binary() when
%    MsgBin :: binary(),
%    DigestType :: 'md5' | 'sha' | 'sha224' | 'sha256' | 'sha384' | 'sha512',
%    KeyBin :: binary().
gen_rsa_sign(MsgBin, DigestType, KeyBin) ->
    io:format(" KeyBin =========~p  ~n", [KeyBin]),
    [Entry] = public_key:pem_decode(KeyBin),
    io:format(" Entry =========~p  ~n", [Entry]),
    RSAPriKey = public_key:pem_entry_decode(Entry),
    SignBin = public_key:sign(MsgBin, DigestType, RSAPriKey),
    base64:encode(SignBin).


%%校验RSA签名
%-spec check_rsa_sign(DataBin, Sign, RSAPublicKeyBin, DigestType) -> boolean when
%    DataBin :: binary(), 
%    Sign :: binary(),
%    RSAPublicKeyBin :: binary()
%   DigestType :: 'md5' | 'sha' | 'sha224' | 'sha256' | 'sha384' | 'sha512'.
check_rsa_sign(DataBin, Sign, RSAPublicKeyBin, DigestType) ->
    PemEntries = public_key:pem_decode(RSAPublicKeyBin),
    RSAPubKey = public_key:pem_entry_decode(hd(PemEntries)),
    Base64Sign = base64:decode(Sign),
    public_key:verify(DataBin, DigestType, Base64Sign, RSAPubKey).

test(S) ->
    DataBin = term_to_binary(S),
    {ok, WWW} = file:read_file("1122.txt"),
    Sign = gen_rsa_sign(DataBin, 'md5', WWW),
    check_rsa_sign(DataBin, Sign, ?RSA_PUBLIC_KEY, 'md5').
% test_create_xml() ->
%     create_xml_with_csv("shopping.csv","shop.xml").

% %%从CSV文件数据源动态创建一个XML，并写入一个shop.xml中
% create_xml_with_csv(CSVFile,XmlFile) ->
%     case file:read_file(CSVFile) of       %%将整个文件读取到一个二进制数据中
%         {ok,Content} ->
%             NewContent = create_xml(binary_to_list(Content)),
%             file:write_file(XmlFile,NewContent);
%         {error,Why} ->
%             {error,Why}
%     end.

% %%根据CSV的内容，动态地创建购物清单列表
% create_xml(ShoppingList) ->
%     Items = lists:map(fun(L) ->
%                               [Name,Quantity,Price] = string:tokens(L,","),
%                               {item,[{name,Name},{quantity,Quantity},{price,Price}],[]}
%                       end,
%                       string:tokens(ShoppingList,"\n")),
%     xmerl:export_simple([{shopping,[],Items}],xmerl_xml).
% --------------------- 
% 作者：铿锵玫瑰 
% 来源：CSDN 
% 原文：https://blog.csdn.net/fanlinsun/article/details/10594561 
% 版权声明：本文为博主原创文章，转载请附上博文链接！

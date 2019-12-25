-module(pool_compile).

-define(GLOBAL_MODULE, pool_global).

-export([compile_settings/1]).

compile_settings(SettingsList) ->
    code:purge(?GLOBAL_MODULE),
    case dynamic_compile:load_from_string(get_settings_code(SettingsList)) of
        {module, ?GLOBAL_MODULE} ->
            ok;
        Error ->
            Error
    end.

get_settings_code(SettingsList) ->
    binary_to_list(get_settings_code(SettingsList, <<>>)).

get_settings_code([{ServerName, Size} | T], Acc) ->
    ServerName2 = atom_to_binary(ServerName, latin1),
    Size2 = integer_to_binary(Size),
    Function = <<"size('", ServerName2/binary, "') -> {ok, ", Size2/binary, "};\n">>,
    get_settings_code(T, <<Acc/binary, Function/binary>>);

get_settings_code([], AccBody) ->
    AccBody2 = <<AccBody/binary, "size(_) -> {error, not_found}.\n">>,
    ModuleBin = atom_to_binary(?GLOBAL_MODULE, latin1),
    ModuleHeader = <<"-module(", ModuleBin/binary, ").\n -export([size/1]).\n">>,
    <<ModuleHeader/binary, AccBody2/binary>>.
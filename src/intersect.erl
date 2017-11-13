-module(intersect).
-compile(export_all).

token_format(Cstr,Argstrs)->
    Clist  = string:tokens(Cstr,"~s"),
    do_token_format(Clist,Argstrs,[]).

do_token_format([],_,Res)->
    Res;
do_token_format([HClist|LClist],Argstrs,Res) when is_list(HClist) ->
    NewRes = 
    if
        Argstrs =:= []->
            LArgstrs = [],
            Res ++ lists:append([HClist|LClist]);
        true->
            [HArgstrs|LArgstrs] = Argstrs,
            if
                is_binary(HArgstrs) ->
                    Res ++ HClist ++ binary_to_list(HArgstrs);
                true->
                    Res ++ HClist ++ HArgstrs
            end
    end,
    do_token_format(LClist, LArgstrs, NewRes);
do_token_format(Clist,_,Res)->
    Res ++ Clist.
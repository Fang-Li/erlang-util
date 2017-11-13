-module(dict_demo).
-compile(export_all).

new()->
    ok.

% D = dict:new(),
% D1 = dict:store(k1, v1, D).
% {dict,1,16,16,8,80,48, {[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]}, {{[],[[k1|v1]],[],[],[],[],[],[],[],[],[],[],[],[],[],[]}}}
% 
% D = dict:new(),
% D1 = dict:store(k1, v1, D),
% D2 = dict:store(k2, v2, D1),
% dict:to_list(dict:store(k2, v3, D2)).

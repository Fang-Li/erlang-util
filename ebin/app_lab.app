%% {application, app_lab,
%%  [{description, "Channel allocator"},
%%   {vsn, "1"},
%%   {modules, []},
%%   {registered, [app_lab]},
%%   {applications, [kernel, stdlib]},
%%   {mod, {app_lab,[]}},
%%   {env, []}
%%  ]}. 

%% {mod, {test_app,[]}} 参数，意思是告诉 erlang 要调用应用模块（test_app）的start/2 函数


{application,app_lab,  
   [{description,"Test application"},  
    {vsn,"1.0.0"},  
    {modules,[app_lab,app_lab_sup]},  
    {registered,[app_lab]},  
    {mod,{app_lab,[]}},  
    {env,[{a,b}]},  
    {applications,[kernel,stdlib]}]}.
-module(include2).
-compile(export_all).

% -import(include).
% -include("src/include.erl").%%不好使
test() ->
  % error_logger:info_msg(import,#state{}).
  error_logger:info_msg(pwd,c:pwd()),
  ok.
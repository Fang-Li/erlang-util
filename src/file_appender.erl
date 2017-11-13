-module(file_appender).
-behaviour(gen_event).

-compile(export_all).

-define(ROTATION_CHECK, 10).

-define(DEFAULT_CONF,"log4erl.conf").

-define(DEFAULT_FORMAT, "[%L] %l%n").

-define(DEFAULT_LEVEL, warn).

-define(DEFAULT_LOGGER, default_logger).
-define(DEFAULT_LOGGER_GUARD, default_logger_guard).

-define(FILE_OPTIONS,[write, raw, binary, append]).
-define(FILE_OPTIONS_ROTATE,[write, raw, binary]).

%-define(DEBUG, true).

-ifdef(DEBUG).
-define(LOG(X), io:format("[~p:~p] " ++ X ++ "~n",[?MODULE, ?LINE])).
-define(LOG2(X,D), io:format("[~p:~p] " ++ X ++ "~n",[?MODULE, ?LINE | D])).
-else.
-define(LOG(_X), ok).
-define(LOG2(_X,_D), ok).
-endif.

-record(log_type,{type, max}).

-record(file_appender, {dir, file_name, fd, counter, log_type, rotation, suffix, level, format=?DEFAULT_FORMAT}).

-record(console_appender, {level=?DEFAULT_LEVEL, format=?DEFAULT_FORMAT}).

-record(rotation_state, {state, timer}).

-record(smtp_appender, {level=?DEFAULT_LEVEL, srvr_opts, auth_opts, msg_opts}).
-record(srvr_opts, {ip, port}).
-record(auth_opts, {username, password}).
-record(msg_opts, {from, to, title, msg=?DEFAULT_FORMAT}).

-record(syslog_appender, {level=?DEFAULT_LEVEL, facility=user,host,port=415, socket, format=?DEFAULT_FORMAT}).

%% log record
-record(log, {level, msg, data, time, millis}).


conf() ->
  File_appender =
  {
		dir = ".",
		level = info,
		file = my_app,
		type = time,
		max = 60,
		suffix = log,
		rotation = 10,
		format = '[%L]: %I, %l%n'
	},
  _Console_appender =
  {
		level = warn,
		format = '%T %j [%L] %l%n'
	},
  File_appender.


































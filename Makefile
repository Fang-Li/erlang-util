all: parse_trans user_default
	@erl -pa ebin -pa ebin/recon  -s make all -s init stop
parse_trans:
	@erlc -o ebin src/parse_trans.erl
user_default:
	@erlc  user_default.erl
live:
	@erl -pa ebin -eval "{ok,FileLists} = file:list_dir(ebin), \
	try \
	[ begin \
		[File|Suffix] = string:tokens(FileName,\".\") , \
		case Suffix=="beam" of \
			true -> File2 = erlang:list_to_atom(File); \
			_ -> File2 = erlang \
		end, \
		erlang:apply(File2,module_info,[]) \
	  end  ||  FileName <- FileLists , FileName =/= \"nif_c.beam\"], \
	  make:all([{compile,export_all},debug_info]) \
	catch ERROR:REASON -> \
			io:format(\"stack .. ~p~n\",[erlang:get_stacktrace()]), \
			io:format(\"~p:~p~n\",[ERROR,REASON]) \
	end." \
	-s reloader
clean:
	@rm -rf ebin/*.beam

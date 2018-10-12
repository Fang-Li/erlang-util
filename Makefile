all:
	@erl -pa ebin -s make all -s init stop
live:
	@erl -pa ebin -eval "{ok,FileLists} = file:list_dir(ebin), \
	[ begin \
		[File,Suffix] = string:tokens(FileName,\".\") , \
		File2 = erlang:list_to_atom(File), \
		erlang:apply(File2,module_info,[]) \
	  end  ||  FileName <- FileLists , FileName =/= \"nif_c.beam\"], \
	  make:all([{compile,export_all},debug_info])."

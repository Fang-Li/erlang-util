all:
	@erl -detached -pa ebin -pa ebin/recon  -s make all -s init stop

clean:
	@rm -rf ebin/*.beam

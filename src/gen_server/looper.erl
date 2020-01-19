-module(looper).

-compile(export_all).

loop() ->
     receive 
        abc -> 
                  io:format("Receive abc. ~n "),
                  loop();
        stop-> 
                  io:format("stop"),
                  stop
      end.  
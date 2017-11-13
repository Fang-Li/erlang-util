-module(apntest).
-export([connect/0]).

connect() ->
    application:start(asn1),
    application:start(crypto),
    application:start(public_key),
    application:start(ssl),
    Address = "gateway.sandbox.push.apple.com",
    Port = 2195,
    Cert = "cert.pem",
    Options = [{certfile, Cert}, {mode, binary}],
    Timeout = 10000,
    case ssl:connect(Address, Port, Options, Timeout) of
        {ok, Socket} ->
            PayloadString = "{\"aps\":{\"alert\":\"Hello world.\",\"sound\":\"chime\", \"badge\":1}}",
            Payload = list_to_binary(PayloadString),
            PayloadLength = size(Payload),
            Packet = <<0:8,
                       32:16/big,                
                       16#ff496f96352abb7c875bedfc755287e14bfadade9ff6ba75360de65441:256/big,
                       PayloadLength:16/big,
                       Payload/binary>>,
            ssl:send(Socket, Packet),
            ssl:close(Socket),
            PayloadString;
        {error, Reason} ->
            Reason
    end.
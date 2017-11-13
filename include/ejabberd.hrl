-record(jid, {user, server, resource, luser, lserver, lresource}).

-record(iq, {id = "",
	     type,
	     xmlns = "",
	     lang = "",
	     sub_el}).

-record(xmlelement, {name = ""     :: string(),
                     attrs = []    :: [{string(), string()}],
                     children = [] :: [{xmlcdata, iodata()} | xmlelement()]}).

-type xmlelement() :: #xmlelement{}.

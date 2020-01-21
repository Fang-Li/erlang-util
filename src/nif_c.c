#include "erl_nif.h"
#include <stdlib.h>
#include <stdio.h>

static ERL_NIF_TERM echo(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
//   double load[3];
   char buf[30];
   ErlNifBinary value;
   if (!enif_inspect_binary(env,argv[0], &value)) {
        return enif_make_badarg(env);
    }
   sprintf(buf, "%s,%s", "hello world",value.data);

   //return enif_make_string(env, buf, ERL_NIF_LATIN1);
   return enif_make_atom(env,"1");
}

static ErlNifFunc nif_funcs[] =
{
   {"b", 1, echo}
};

ERL_NIF_INIT(nif_c,nif_funcs,NULL,NULL,NULL,NULL)


// gcc -o nif_c.so -fpic -shared -I /data/service/erlang19.3/lib/erlang/erts-8.3/include/  nic_c.c
// gcc -o nif_c.so -fpic -shared -I /Users/lifang/service/otp20.3.8/lib/erlang/erts-9.3.3/include/  src/nic_c.c
-module(ex22).
-export([start/0, parpadea/1, temps/2, espera/2, pampalluga/2]).
-import(bots1,[nou/2,crearBotonera/2,crearBotons/3,loop/4]).

start()->
	B=bots1:nou(6,self()),
	parpadea(B).

parpadea(B)->
	receive
	{clicked,Pis}-> B!{light_on,Pis},
		spawn(?MODULE,temps,[B,Pis]),
		parpadea(B);
	abort -> B!close
	end.
temps(B, Pis)->
	espera(B,Pis).

espera(B,Pis) ->
    receive
	abort ->
	    B!close
    after
	20000 ->
	    pampalluga(B,Pis)
    end.

pampalluga(B,Pis) ->
    B!{light_off,Pis},
    timer:sleep(500),
    B!{light_on,Pis},
    timer:sleep(500),
    B!{light_off,Pis},
    timer:sleep(500),
    B!{light_on,Pis},
    timer:sleep(500),
    B!{light_off,Pis},
    timer:sleep(500),
    B!{light_on,Pis},
    timer:sleep(500),
    B!{light_off,Pis},
    timer:sleep(500),
    B!{light_on,Pis},
    timer:sleep(500),
    B!{light_off,Pis},
    timer:sleep(500),
    B!{light_on,Pis},
    timer:sleep(500),
    B!{light_off,Pis}.
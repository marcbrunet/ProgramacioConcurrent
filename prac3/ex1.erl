-module(ex1).
-export([start/0, enciendepisos/2, loop/1, apagapisos/2, test/2]).
-import(bots,[nou/2,crearBotonera/2,crearBotons/3,loop/4]).

start()->
    B=bots:nou(10,self()),
    loop(B).

enciendepisos(Pid,9)->
    Pid!{light_on,9};  
enciendepisos(Pid, Pis) ->    
    Pid!{light_on, Pis},
    enciendepisos(Pid, Pis+1).

apagapisos(Pid,9)->
    Pid!{light_off,9};
apagapisos(Pid, Pis) ->
    Pid!{light_off,Pis},
    apagapisos(Pid,Pis+1).

test(B,Pis)->
    receive
	{clicked,N} when N >= Pis ->
	    apagapisos(B,0);
	{clicked,N} when N < Pis -> 
	    test(B,Pis)
    end.
		       
loop(B)->
    receive
	abort -> apagapisos(B,0),B! close;
	{clicked,Pis}  ->
	    enciendepisos(B,Pis),
	    test(B,Pis),
	    loop(B);
	other -> loop(B)
    end.

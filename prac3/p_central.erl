-module(p_central).
-export([central/1,cen/2,enciende_pisos/2,apaga_pisos/2,cierra_botoneras/1]).
-import(bots,[nou/2,crearBotonera/2,crearBotons/3,loop/4]).

central(PidControl)->
    spawn(?MODULE,cen,[PidControl,[]]).

cen(PidControl,Lista_botoneras)->
    receive
	{new,Lista_estats}->
	    Id=bots:nou(8,self()),
	    enciende(Id,Lista_estats),
	    cen(PidControl,[Id|Lista_botoneras]);
	close ->
	    cierra_botoneras(Lista_botoneras),
	    cen(PidControl,[]);
	{light_on,Pis} ->
	    enciende_pisos(Pis,Lista_botoneras),
	    cen(PidControl,Lista_botoneras);
	{light_off,Pis} ->
	    apaga_pisos(Pis,Lista_botoneras),
	    cen(PidControl,Lista_botoneras);
	abort ->
	    PidControl!abort;
	    	
	{clicked,Pis}->
	    PidControl!{clicked,Pis},
	    cen(PidControl,Lista_botoneras)	    
	end.
enciende_pisos(Pis,LB)->
    lists:map(fun(A)-> A!{light_on,Pis}end,LB).
apaga_pisos(Pis,LB)->
    lists:map(fun(A)-> A!{light_off,Pis}end,LB).
cierra_botoneras(LB)->
    lists:map(fun(A)-> A!close end,LB).
enciende(Id,Lista)->
    lists:map(fun(A)->Id!{light_on,A}end,Lista).

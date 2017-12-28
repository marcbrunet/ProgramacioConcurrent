-module(ex3).
-export([start/0, comunicacio/3, enciendeparells/1,enciendesenars/1, apagaparells/1, apagasenars/1]).
-import(bots,[nou/2,crearBotonera/2,crearBotons/3,loop/4]).
%necesitamos crear dos procesos diferentes para dos botoneras
% una de dos botones y la otra de 8
start()->
    B1=bots:nou(2,self()),
    B2=bots:nou(8,self()),
    comunicacio(B1,B2,0).

comunicacio(B1,B2,Estat)->
    receive
	abort->
	    B1!close,
	    B2!close;
	{clicked,Pis} when Estat ==0 ->
	    if (Pis rem 2) == 0->
		    enciendeparells(B2),
		    comunicacio(B1,B2,1);
	       (Pis rem 2) /= 0 ->
		    enciendesenars(B2),
		    comunicacio(B1,B2,1)
	    end;
	{clicked,Pis} when Estat==1->
	    if (Pis rem 2) == 0->
		    apagaparells(B2),
		    comunicacio(B1,B2,0);
	       (Pis rem 2) /= 0 ->
		    B2!{light_on,Pis},
		    apagasenars(B2),
		    comunicacio(B1,B2,0)
	    end
	end.

enciendeparells(Pid)->
    Pid!{light_on,0},
    Pid!{light_on,2},
    Pid!{light_on,4},
    Pid!{light_on,6}.

enciendesenars(Pid)->
    Pid!{light_on,1},
    Pid!{light_on,3},
    Pid!{light_on,5},
    Pid!{light_on,7}.
apagaparells(Pid)->
    Pid!{light_off,0},
    Pid!{light_off,2},
    Pid!{light_off,4},
    Pid!{light_off,6}.

apagasenars(Pid)->
    Pid!{light_off,1},
    Pid!{light_off,3},
    Pid!{light_off,5},
    Pid!{light_off,7}.

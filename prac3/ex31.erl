-module(ex31).
-export([start/0, proxy1/1,proxy2/1, loop/2,bucle/2,enciendeparells/1,enciendesenars/1, apagaparells/1, apagasenars/1]).
-import(bots,[nou/2,crearBotonera/2,crearBotons/3,loop/4]).
%necesitamos crear dos procesos diferentes para dos botoneras
% una de dos botones y la otra de 8
start()->
    P1=proxy1(self()),
    P2=proxy2(self()),
    bucle(P1,P2).

proxy1(_)->
    A=spawn(?MODULE,loop,[self(),b2]),
    bots:nou(2,A).
proxy2(_)->
    B=spawn(?MODULE,loop,[self(),b8]),
    bots:nou(8,B).

loop(Pid,Bot)->
    receive
	{clicked,Pis}->
	    Pid!{clicked,Bot,Pis},
	    loop(Pid,Bot);
	abort ->
	    Pid!close
    end.

bucle(P1,P2)->
    receive
	abort ->
	    P1!abort,
	    P2!abort;
	{clicked,b2,Pis} when Pis == 1 ->
	    enciendesenars(P2),
	    bucle(P1,P2);
	
	{clicked,b2,Pis}  when Pis == 0->
	    enciendeparells(P2), 
	    bucle(P1,P2);
	{clicked,b8,Pis} when Pis rem 2 == 0 ->
	    apagaparells(P2),
	    bucle(P1,P2);
	
	{clicked,b8,Pis}  when Pis rem 2 /= 0 ->
	    apagasenars(P2),
	    bucle(P1,P2)
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

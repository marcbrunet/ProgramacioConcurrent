-module(ex21).
-export([start/0,loopEncen/3,encen/2,apaga/2]).
-import(bots1,[nou/2,crearBotonera/2,crearBotons/3,loop/4]).


start()->
    A=bots1:nou(10,self()),
    loopEncen(A,0,0).

encen(Pid,9)->
    Pid!{light_on,9};
encen(Pid,Id)->
    Pid!{light_on,Id},
    encen(Pid,Id+1).

apaga(Pid,9)->
    Pid!{light_off,9};
apaga(Pid,Id)->
    Pid!{light_off,Id},
    apaga(Pid,Id+1).
			 

loopEncen(A,Pis,Estat)->
    receive

	abort->A!abort;
	{clicked, Id} when Estat == 0 ->
	    encen(A,Id),
	    loopEncen(A,Id,1);
	{clicked, Id} when Estat == 1, Id > Pis ->
	    apaga(A,Pis),
	    loopEncen(A,Id,0);
	Other ->
	    loopEncen(A,Pis,Estat)
    end.



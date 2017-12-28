-module(ex2).
-export([start/0, inici/1, ciclo/2, parpadeo/3]).
-import(bots,[nou/2,crearBotonera/2,crearBotons/3,loop/4]).

start()->
    B=bots:nou(6,self()),
    inici(B).
%para cada
inici(B)->
    receive
	{clicked, Pis}->
	    spawn(?MODULE,ciclo,[B,Pis]),
	    inici(B);
	abort-> B!close
    end.
ciclo(B,Pis)->
    receive
    after 2000->
	    B!{light_on,Pis},
	    parpadeo(B,Pis,20)
    end.

parpadeo(B, Pis,N)->
    if N==0->
	    B!{light_off,Pis};
       N rem 2 ==0 -> 
	    B!{light_off,Pis},
	    timer:sleep(500),
	    parpadeo(B,Pis,N-1);
       
       N rem 2 /= 0 ->
	    B!{light_on,Pis},
	    timer:sleep(500),
	    parpadeo(B,Pis,N-1)
       end.

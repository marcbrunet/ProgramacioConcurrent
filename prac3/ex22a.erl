-module(ex22a).
-export([start/0,loopEA/1,afterEncen/3,afterApaga/3,espera20/2,loop_500ms/3,proces/2]).
-import(bots1,[nou/2,crearBotonera/2,crearBotons/3,loop/4]).


start()->
    Pid=bots1:nou(6,self()),%abans 10
    loopEA(Pid).

afterEncen(Pid,Id,Ms)->
    Pid!{light_off,Id},
    receive
    after Ms -> Pid!{light_on,Id}
    end.


afterApaga(Pid,Id,Ms)->
    Pid!{light_on,Id},
    receive
    after Ms -> Pid!{light_off,Id}
    end.

espera20(Pid,Id)->
    afterApaga(Pid,Id,20000).

loop_500ms(Pid,Id,1)->
    afterApaga(Pid,Id,500),
    afterEncen(Pid,Id,500);

loop_500ms(Pid,Id,Segons)->
    afterApaga(Pid,Id,500),
    afterEncen(Pid,Id,500),
    loop_500ms(Pid,Id,Segons-1).
	

proces(Pid,Id)->
    espera20(Pid,Id),
    loop_500ms(Pid,Id,5),
    Pid!{light_off,Id}.

			 

loopEA(Pid)->
    receive

	abort->Pid!abort;

	{clicked, Id}->
	    spawn(ex22a,proces,[Pid,Id]),
	    loopEA(Pid)
	
    end.



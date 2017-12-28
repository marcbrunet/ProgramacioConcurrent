-module(control).
-export([b_central/0,proxy/2,loop/3]).
-import(bots,[nou/2,crearBotonera/2,crearBotons/3,loop/4]).
-import(p_central,[central/0,cen/2,enciende_pisos/2,apaga_pisos/2,cierra_botoneras/1]).

b_central()->
    PidCentral = p_central:central(self()),
    register(bot_central,PidCentral),
    PidProxy=spawn(?MODULE,proxy,[self(),b2]),
    bots:nou(2,PidProxy),
    loop(self(),PidCentral,[0,0,0,0,0,0,0,0]).

proxy(PidMain,Bot)->
    receive
	{clicked,Pis}->
	    PidMain!{clicked,Pis,Bot},
	    proxy(PidMain,Bot);
	abort ->
	    PidMain!{abort,Bot}
    end.
loop(PidMain,PidCentral,Lista_estats)->
    receive
	{clicked,Pis,b2} when Pis==1->
	    bot_central!{new,Lista_estats},
	    loop(PidMain,PidCentral,Lista_estats);
	{clicked,Pis,b2}  when Pis ==0->
	    bot_central!close,
	    loop(PidMain,PidCentral,Lista_estats);
	{clicked,Pis}->
	    B=lists:member(Pis,Lista_estats),
	    if B->
		    PidCentral!{light_off,Pis},
		    Lista=lists:filter( fun(L)-> L /= Pis end,Lista_estats),
		    loop(PidMain,PidCentral,Lista);
	       true -> 
		    PidCentral!{light_on,Pis},
		    loop(PidMain,PidCentral,[Pis|Lista_estats])
	    end
	end.
%lista de encendidos
    

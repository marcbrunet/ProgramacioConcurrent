-module(ascensor).
-export([ascensor/0,inici/5,reset/2]).
-define(TOP,22).
-define(MIN,0).

ascensor()->
    Cabina=bcab:new(4,self()),
    Sensor=sensor:sensor_init(self()),
    Motor=motor:start(Sensor),
    receive
	ready->
	    reset(Cabina,Motor)
    end.
reset(Cabina,Motor)->
    Motor!run_down,
    Cabina!{display,"RESET"},
    receive
	at_bottom ->
	    Cabina!{display,"BOTTOM"},
	    Motor!stop,
	    Motor!run_up,
	    receive
		{sens_pl,_}->
		    Motor!stop,
		    inici(Cabina,Motor,0,0,0)
	    end
    end.	
    
inici(Cabina,Motor,Posicion,Destino,Estat)->
    receive
	at_top->
	    Motor!stop,
	    Cabina!{display,"TOP"},
	    inici(Cabina,Motor,?TOP,Destino,0);
	at_bottom->
	    Motor!stop,
	    Cabina!{display,"BOTTOM"},
	    inici(Cabina,Motor,?MIN,Destino,0);
	ready->
	    inici(Cabina,Motor,Posicion,1,0);
	abort->
	    Motor!kill,
	    Cabina!kill,close;
	{clicked,Pis} when Pis == Posicion->
	    io:format("misma posicion ~n"),
	    inici(Cabina,Motor,Posicion,Pis,0);
	{clicked,Pis} when Pis < Posicion ->
	    if Estat == 0 ->
		    Motor!run_down,
		    Cabina!{light_on,Pis},
		    inici(Cabina,Motor,Posicion,Pis,1);
	       true ->
		    inici(Cabina,Motor,Posicion,Destino,1)
	    end;
   	{clicked,Pis} when Pis > Posicion ->
	    if Estat == 0->
		    Cabina!{light_on,Pis},
		    Motor!run_up,
		    inici(Cabina,Motor,Posicion,Pis,1);
	       true -> 
		    inici(Cabina,Motor,Posicion,Destino,1)
	    end;
	{sens_pl,Pis} when Pis == Destino->
	    io:format("hemos llegadp al piso:~p~n", [Destino]),
	    Motor!stop,
	    Cabina!{light_off,Pis},
	    Cabina!{display,Destino},
	    inici(Cabina,Motor,Pis,Destino,0);
	 {sens_pl,Pis} ->
	    io:format("Destino~p~n",[Destino]),
	    io:format("Estamos pis->~p~n",[Pis]),
	    Cabina!{display,Pis},
	    inici(Cabina,Motor,Pis,Destino,1)
    end.
		
	

    

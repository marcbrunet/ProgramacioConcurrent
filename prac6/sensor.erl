-module(sensor).
-export([sensor_init/0,loopSensor/1]).
-define(sens_pl1,0.5).
-define(sens_pl2,5.5).
-define(sens_pl3,8.5).
-define(sens_pl4,12.5).

%creamos otro proceso q recive los siguientes mensajes
% este proceso recibe mensaje del motor y lo evia al proceso central ascensor
sensor_init()->
    register(sensor,spawn(sensor,loopSensor,[0])),
    ascensor!ready.

pos(Pos)->
    ascensor!{sens_pl,Pos}.
  
loopSensor(Pos)->
    receive
	at_bottom->
	    ascensor!at_bottom,
	    loopSensor(Pos);
	at_top->
	    ascensor!at_top,
	    loopSensor(Pos);
	ready->
	    ascensor!ready,
	    loopSensor(Pos);
	kill-> 
	   ok;
	    
	{at,Pos_actual} ->
	    if ((Pos_actual >= ?sens_pl1) and (Pos < ?sens_pl1)) or((Pos > ?sens_pl1) and (Pos_actual =< ?sens_pl1)) ->
		    pos(0);
	       
	       ((Pos_actual >= ?sens_pl2) and (Pos < ?sens_pl2)) or((Pos > ?sens_pl2) and (Pos_actual =< ?sens_pl2))->
		    pos(1);
	       
	       ((Pos_actual >= ?sens_pl3) and (Pos < ?sens_pl3)) or((Pos > ?sens_pl3) and (Pos_actual =< ?sens_pl3))->
		    pos(2);
	       
	       ((Pos_actual >= ?sens_pl4) and (Pos < ?sens_pl4)) or((Pos > ?sens_pl4) and (Pos_actual =< ?sens_pl4))->
		    pos(3);
	       true->
		    ok
	    end,
	    loopSensor(Pos_actual)
    end.



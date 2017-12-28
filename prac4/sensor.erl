-module(sensor).
-export([sensor_init/1,loopSensor/2]).
-define(sens_pl1,0.5).
-define(sens_pl2,5.5).
-define(sens_pl3,8.5).
-define(sens_pl4,12.5).

%creamos otro proceso q recive los siguientes mensajes
% este proceso recibe mensaje del motor y lo evia al proceso central ascensor
sensor_init(PidAs)->
    PidS=spawn(?MODULE,loopSensor,[PidAs,0]),
    PidAs!ready,
    PidS.

loopSensor(PidAs,Pos)->
    receive
	ready->
	    PidAs!ready,
	    loopSensor(PidAs,Pos);
	at_bottom->
	    PidAs!at_bottom,
	    loopSensor(PidAs,Pos);
	at_top->
	    PidAs!at_top,
	    loopSensor(PidAs,Pos);
	kill-> 
	    PidAs!kill;
	    
	{at,Pos_actual} ->
	    if ((Pos_actual >= ?sens_pl1) and (Pos < ?sens_pl1)) or((Pos > ?sens_pl1) and (Pos_actual =< ?sens_pl1)) ->
		    PidAs!{sens_pl,0};
	       
	       ((Pos_actual >= ?sens_pl2) and (Pos < ?sens_pl2)) or((Pos > ?sens_pl2) and (Pos_actual =< ?sens_pl2))->
		    PidAs!{sens_pl,1};				    
	       
	       ((Pos_actual >= ?sens_pl3) and (Pos < ?sens_pl3)) or((Pos > ?sens_pl3) and (Pos_actual =< ?sens_pl3))->
		    PidAs!{sens_pl,2};				    
	       
	       ((Pos_actual >= ?sens_pl4) and (Pos < ?sens_pl4)) or((Pos > ?sens_pl4) and (Pos_actual =< ?sens_pl4))->
		    PidAs!{sens_pl,3};
	       true->
		    loopSensor(PidAs,Pos_actual)
	    end,
	    loopSensor(PidAs,Pos_actual)
    end.



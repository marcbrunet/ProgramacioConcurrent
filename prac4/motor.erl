-module(motor).
-export([start/1, loopMotor/2, sube/2, baja/2]).
-define(VELCAB,0.6). %velocidad de la cabina
-define(RESOL,100).
-define(MAXREC,22).
-define(DESPL, ?VELCAB *(?RESOL / 1000)).
%Pid-> es el pid del proceso al que debe de enviar los mensajes.

%las operaciones que hace son  run_up o ran_down.
% si el motor esta encencidido, la cabina se desplaza i va cambiando su 
% posiscion
start(PidS)->
    spawn(?MODULE,loopMotor,[PidS,1]).

loopMotor(PidS,Pos_actual)->
    receive
	run_up->
	    io:format("ascensor subiendo ~n"),
	    sube(PidS,Pos_actual);
	run_down ->
	    io:format("acensor bajando ~n"),
	    baja(PidS,Pos_actual);
	stop ->
	    io:format("es un stop~n"),
	    loopMotor(PidS,Pos_actual);
	kill ->PidS!kill	
    end.
sube(PidS,Pos_actual)->
    receive
	stop-> 
	    loopMotor(PidS,Pos_actual);
	kill-> PidS!kill
    after ?RESOL ->
	    if Pos_actual >= ?MAXREC ->
		    PidS!at_top,
		    loopMotor(PidS,Pos_actual);
	       true->
		    %io:format("Pos-> ~p~n",[Pos_actual]),
		    PidS!{at,(Pos_actual+ ?DESPL)},
		    sube(PidS,(Pos_actual+ ?DESPL))
	    end
    end.

baja(PidS,Pos_actual)->
    receive
	stop->
	    loopMotor(PidS,Pos_actual);
	kill->PidS!kill
    after ?RESOL->
	    if Pos_actual =< 0 ->
		    PidS!at_bottom,
		    %self()!stop
		    loopMotor(PidS,Pos_actual);
	       true ->
		    %io:format("Pos-> ~p~n",[Pos_actual]),
		    PidS!{at,Pos_actual-?DESPL},
		    baja(PidS,Pos_actual-?DESPL)
	    end
    end.

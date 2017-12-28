-module(motor).
-export([start/0, loopMotor/1, sube/1, baja/1,run_up/0,run_down/0,stop/0,kill/0,at_top/0,at_bottom/0]).
-define(VELCAB,0.6). %velocidad de la cabina
-define(RESOL,100).
-define(MAXREC,22).
-define(DESPL, ?VELCAB *(?RESOL / 1000)).
%Pid-> es el pid del proceso al que debe de enviar los mensajes.

%las operaciones que hace son  run_up o ran_down.
% si el motor esta encencidido, la cabina se desplaza i va cambiando su 
% posiscion
start()->
    register(motor,spawn(?MODULE,loopMotor,[0.2])),
    ready().
run_up()-> io:format("motor up!~n"), motor!run_up.
run_down()-> io:format("motor down!~n"),motor!run_down.
stop()-> io:format("motor parado!~n"),motor!stop.
kill()-> motor!kill.
at_pos(Pos)->
    sensor!{at,Pos}.
at_top()->
    sensor!at_top.
at_bottom()->
    sensor!at_bottom.
ready()->
    sensor!ready.

loopMotor(Pos_actual)->
    receive
	run_up->
	    %io:format("ascensor subiendo ~n"),
	    sube(Pos_actual);
	run_down ->
	    %io:format("acensor bajando ~n"),
	    baja(Pos_actual);
	stop ->
	    %io:format("es un stop~n"),
	    loopMotor(Pos_actual);
	kill -> sensor!kill	
    end.
sube(Pos_actual)->
    receive
	stop-> 
	    loopMotor(Pos_actual);
	kill-> kill()
    after ?RESOL ->
	    if Pos_actual >= ?MAXREC ->
		    at_top(),
		    loopMotor(Pos_actual);
	       true->
		    %io:format("Pos-> ~p~n",[Pos_actual]),
		    at_pos(Pos_actual+ ?DESPL),
		    sube((Pos_actual+ ?DESPL))
	    end
    end.

baja(Pos_actual)->
    receive
	stop->
	    loopMotor(Pos_actual);
	kill-> kill()
    after ?RESOL->
	    if Pos_actual =< 0 ->
		    at_bottom(),
		    loopMotor(Pos_actual);
	       true ->
		    %io:format("Pos-> ~p~n",[Pos_actual]),
		    at_pos(Pos_actual-?DESPL),
		    baja((Pos_actual-?DESPL))
	    end
    end.

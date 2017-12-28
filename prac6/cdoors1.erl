-module(cdoors1).
-compile(export_all).

-define(OPENING,2000).
-define(OPEN,5000).
-define(CLOSING,2000).

start()->
    register(doors,spawn(?MODULE,loop_door,[])).

open()->
    doors!{open}.
close()->
    doors!{close}.
kill()->
    doors!kill.
    
loop_door()->
    receive
	kill ->
	    exit(normal);
	{open}->
	    abrir(0);
	{close} ->
	    ascensor:doors_closed(),
	    loop_door()
    end.

abrir(?OPENING)->
   %si hemos cumplido el tiempo, puertas estarana biertas
   % y vamos a mantenerlas abiertas
    ascensor:doors_open(),
    abierto();
abrir(T) ->
    receive 
	kill ->
	    exit(normal);
	{open}->
	    abrir(T);
	{close} ->
	    cerrar(T)
    after 50 ->
	    abrir(T+50)
    end.

abierto()->
    receive
	kill ->
	    exit(normal);
	{close}->
	    cerrar(0);
	{open} ->
	    
	    abierto()
    after ?OPEN ->
	    ascensor:doors_closing(),
	    cerrar(0)
    end.


cerrar(?CLOSING)->
    ascensor:doors_closed(),
    loop_door();
cerrar(T) ->
    receive
	kill ->
	    exit(normal);
	{open}->
	    abrir(T);
	{close} ->
	    cerrar(T)
    after 50 ->
	    cerrar(T+50)
    end.

		
		

-module(ascensor).
-export([start/0,inici/3,reset/0,pbc_pushed/1,kill/0,pushed/1,abort/0,doors_open/0,doors_closed/0,doors_closing/0,espera_puertas/1,moviment_ascensor/1]).
-define(TOP,22).
-define(MIN,0).

% funciones publicas que utilizaran otros modulos
% mensaje que recibiremos de las puertas
doors_open()->
    ascensor!{doors_open}.
doors_closed()->
    ascensor!{doors_closed}.
doors_closing()->
    ascensor!{doors_closing}.

%mensajes que vienen de la botonera principal
pbc_pushed(open_doors)->
    ascensor!{open_doors};
pbc_pushed(close_doors) ->
    ascensor!{close_doors};
pbc_pushed(Pis) ->
    ascensor!{clicked,Pis}.
%mensajes que vienen de las botoneras de cada planta
pushed(Pis)->
    ascensor!{clicked,(Pis-1)}.

abort()->
    wxenv:kill(),
    bcab:kill(),
    cdoors1:kill(),
    ascensor!abort.

kill()->
    wxenv:kill(),
    io:format("aqui~n"),
    cdoors1:kill(),
    ascensor!abort.
start()->
    register(ascensor,self()),
    wxenv:start(),
    bcab:new(4),
    sensor:sensor_init(),
    motor:start(),
    bppool:start(4),
    cdoors1:start(),
    bcab:display("RESET"),
    receive
	ready->
	    reset()
    end,
    io:format("RESET HECHO, Ya podemos utilizar el ascensor~n"),
    inici(0,0,0).

reset()->
    motor:run_down(),
    receive
	at_bottom->
	    bcab:display("BOTTOM"),
	    motor:stop(),
	    motor:run_up(),
	    receive
		{sens_pl,_}->
		    motor:stop()
	    end
    end.

inici(Posicion,Destino,Estado)->
    bcab:display(Posicion),
    receive
	at_top->
	    motor:stop(),
	    bcab:display("TOP"),
	    inici(?TOP,Destino,Estado);
	at_bottom ->
	    motor:stop(),
	    bcab:display("BOTTOM"),
	    inici(?TOP,Destino,Estado);
	abort->
	    motor:kill(),              
	    	  
	    bppool:kill(),
	    unregister(ascensor);
	%mensaje que vienen dentro del ascensor y de cada planta
	{clicked,Pis} when Pis == Posicion->
	    
	    if Estado == 0->
		    bppool:display(Pis,"OPENING"),
		    cdoors1:open(),
		    espera_puertas(Pis);
	       true ->
		    inici(Posicion,Destino,Estado)
	    end;
	
	{clicked,Pis} when Pis < Posicion  ->
	    if Estado ==0->
		    bcab:set_light(Pis,on),
		    bppool:set_light(Pis,all,on),
		    bppool:display_all("BUSY"),
		    bppool:display(Pis,Posicion),
		    motor:run_down(),
		    moviment_ascensor(Pis);
	       true ->
		    timer:sleep(50),
		    ascensor!{clicked,Pis},
		    inici(Posicion,Pis,1)
	    end;		    
	{clicked,Pis} when Pis > Posicion  ->
	    if Estado == 0->
		    bcab:set_light(Pis,on),
		    bppool:set_light(Pis,all,on),
		    bppool:display_all("BUSY"),
		    bppool:display(Pis,Posicion),
		    motor:run_up(),
		    moviment_ascensor(Pis);
	       true ->
		    timer:sleep(50),
		    ascensor!{clicked,Pis},
		    inici(Posicion,Pis,1)
	    end;
	% mensajes que viene de la botonera
	{open_doors}  when Estado == 0->        %si estamos parados
	    %si las puesrtas estan cerradas o se estan cerrando
	    bppool:display(Destino,"OPENING"),
	    cdoors1:open(),
	    espera_puertas(Destino);
	    
	{close_doors}  when Estado == 0->       %si ascensor no se mueve
    	    %si tenemos la puerta abierta
	    cdoors1:close(),
	    espera_puertas(Destino)
    end.

moviment_ascensor(Destino)->
    receive
	{sens_pl,Pis} when Pis ==Destino->
	    bcab:display(Pis),
	    bcab:set_light(Pis,off),
	    bppool:set_light(Pis,all,off),
	    bppool:display_all(Pis),
	    bppool:display(Destino,"OPENING"),
	    motor:stop(),
	    cdoors1:open(),
	    espera_puertas(Destino);
		
	{sens_pl,Pis} ->
	    bcab:display(Pis),
	    bppool:display(Destino,Pis),
	    moviment_ascensor(Destino)
    end.


espera_puertas(Destino)->
    receive
	%mensajes desd el cdoors
	{doors_closed}->
	    % puertas totalmente cerradas
	    bppool:display(Destino,"HERE"),
	    inici(Destino,Destino,0);
	{doors_open} ->
	    %puert totaalmente abierta
	    bppool:display(Destino,"OPEN"),
	    espera_puertas(Destino);
	{doors_closing} ->
	    % puertas se estan cerrando
	    bppool:display(Destino,"CLOSING"),
	    espera_puertas(Destino);
	%mensajes desd la bcab
	{open_doors} ->
	    cdoors1:open(),
	    espera_puertas(Destino);
	{close_doors} ->
	    bppool:display(Destino,"CLOSING"),
	    cdoors1:close(),
	    espera_puertas(Destino)
    end.
	    

	






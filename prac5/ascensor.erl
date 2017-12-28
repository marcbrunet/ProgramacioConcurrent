-module(ascensor).
-export([ascensor/0,inici/3,reset/0,pbc_pushed/1,kill/0,pbp_pushed/2,envia_busy/1,mensaje/3,pushed/1,abort/0]).
-define(TOP,22).
-define(MIN,0).

ascensor()->
    register(ascensor,self()),
    wxenv:start(),
    bcab:new(4),
    sensor:sensor_init(),
    motor:start(),
    bppool:start(4),
    receive
	ready->
	    reset()
    end.

pbp_pushed(Pis,_)->
    ascensor!{clicked,Pis}.


pbc_pushed(Id)->
    ascensor!{clicked,Id}.


pushed(Pis)->
    ascensor!{clicked,Pis-1}.

abort()->
    bcab:kill(),
    ascensor!abort.

kill()->
    io:format("aqui~n"),
    ascensor!abort.

reset()->
    motor:run_down(),
    bcab:display("RESET"),                 %Cabina!{display,"RESET"},
    receive
	at_bottom ->
	    bcab:display("BOTTOM"),        %Cabina!{display,"BOTTOM"},
	    motor:stop(),                  %Motor!stop,
	    motor:run_up(),                %Motor!run_up,
	    receive
		{sens_pl,Pos}->
		    motor:stop(),          %Motor!stop,
		    io:format("RESET hecho!~n"),
		    inici(Pos,0,0)
	    end
    end.	
    
inici(Posicion,Destino,Estat)->
    bcab:display(Posicion),
    receive
	at_top->
	    io:format("estoy al TOP~n"),
	    motor:stop(),                %Motor!stop,
	    bcab:display("TOP"),         %Cabina!{display,"TOP"},
	    inici(?TOP,Destino,0);
	at_bottom->
	    io:format("estoy al BOTTOM~n"),
	    motor:stop(),                %Motor!stop,
	    bcab:display("BOTTOM"),      %Cabina!{display,"BOTTOM"},
	    inici(?MIN,Destino,0);
	ready->
	    inici(Posicion,Destino,0);
	abort->
	    motor:kill(),                %Motor!kill,
	    wxenv:kill(),		  %Cabina!kill,close;
	    bppool:kill(),
	    unregister(ascensor);
	
	{clicked,Pis} when Pis == Posicion->
	    if Estat ==0 ->
		    io:format("misma posicion ~n"),
		    inici(Posicion,Posicion,0);
	       
	       true-> inici(Posicion,Destino,1)
	    end;
	{clicked,Pis} when Pis < Posicion ->
	    if Estat == 0 ->
		    
		    bppool:set_light(Pis,up,on),
		    bppool:set_light(Pis,down,on),
		    bppool:set_light(Pis,all,on),
		    envia_busy(Pis+1),
		    io:format("Destino ->~p~n",[Pis]),
		    motor:run_down(),          %Motor!run_down,
		    bcab:set_light(Pis,on),    %Cabina!{light_on,Pis},
		    inici(Posicion,Pis,1);
	       true ->
		    inici(Posicion,Destino,1)
	    end;
   	{clicked,Pis} when Pis > Posicion ->
	    if Estat == 0->
		    bppool:set_light(Pis,up,on),
		    bppool:set_light(Pis,down,on),
		    envia_busy(Pis+1),
		    io:format("Destino -> ~p~n",[Pis]),
		    motor:run_up(),           %Motor!run_up,
		    bcab:set_light(Pis,on),   %Cabina!{light_on,Pis},
		    inici(Posicion,Pis,1);
	       true -> 
		    inici(Posicion,Destino,1)
	    end;
	{sens_pl,Pis} when Pis == Destino->
	    io:format("hemos llegadp al piso:~p~n", [Destino]),
	    motor:stop(),                    %Motor!stop,
	    bppool:display(Pis+1,"HERE"),
	    envia_pis((Pis+1)),
	    bcab:set_light(Pis,off),         %Cabina!{light_off,Pis},
	    bcab:display(Destino+1),           %Cabina!{display,Destino},
	    bppool:set_light(Pis,up,off),
	    bppool:set_light(Pis,down,off),
	    inici(Pis,Destino,0);
	 {sens_pl,Pis} ->
	    io:format("Destino -> ~p~n",[Destino]),
	    io:format("Estamos pis->~p~n",[Pis]),
	    bppool:display(Destino+1,Pis),
	    bcab:display(Pis),               %Cabina!{display,Pis},
	    inici(Pis,Destino,1)
    end.
		

envia_busy(Destino)->	
    List=lists:seq(1,4),
    mensaje(Destino,List,"BUSY").
envia_pis(Destino)->
    List=lists:seq(1,4),
    mensaje(Destino,List,Destino-1).

mensaje(_,[],_)->
    0;
mensaje(Destino,[Destino|Resta],Mensaje)->
    mensaje(Destino,Resta,Mensaje);
mensaje(Destino,[Pis|Resta],Mensaje)->
    bppool:display(Pis,Mensaje),
    mensaje(Destino,Resta,Mensaje).
	

    

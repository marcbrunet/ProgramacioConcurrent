-module(bppool).
-export([start/1, init/1, set_light/3, display/2, kill/0,difusor/2,display_all/1]).


start(Npis) ->
    register(bppool, spawn(bppool, init, [Npis])).

set_light(Pis, all, State) ->
    bppool!{set_light, Pis, up, State},
    bppool!{set_light, Pis, down, State};
set_light(Pis, Dir, State) ->
    bppool!{set_light, Pis, Dir, State}.

display(Pis, M) ->
    bppool!{display, Pis, M}.
display_all(M)->
    bppool!{display,all,M}.

kill() ->
    
    bppool!kill.

init(Npis) ->
    Lista_bot_pisos = crear_botoneras(1,Npis),
    loop(Lista_bot_pisos).

crear_botoneras(I, Npis) when I>Npis ->
    [];
crear_botoneras(I, Npis) ->
    Pid = bpis1:new(I),
    [Pid|crear_botoneras(I+1, Npis)].

difusor(Lista_bot_pisos, Mensaje) ->
    lists:map(fun(Pis)-> Pis!Mensaje end,Lista_bot_pisos),
    ok.
		      

loop(Lista_bot_pisos) ->
    receive
	{set_light, Pis, Dir, State} ->
	    bpis1:set_light(lists:nth((Pis+1),Lista_bot_pisos ), Dir, State),
	    loop(Lista_bot_pisos);
	{display, all, Mensaje} ->
	    lists:map(fun(Pis)-> bpis1:display(Pis, Mensaje) end, Lista_bot_pisos),
	    loop(Lista_bot_pisos);
	{display, Pis, Mensaje} ->
	    bpis1:display(lists:nth((Pis+1), Lista_bot_pisos), Mensaje),
	    loop(Lista_bot_pisos);
	kill ->
	    io:format("matamos botoneas de los pisos~n"),
	    difusor(Lista_bot_pisos, kill),
	    exit(normal),
	    ok;
	abort->
	    ok;
	_ ->
	    loop(Lista_bot_pisos)
    end.


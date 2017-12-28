-module(cdoors).
-compile(export_all).

-define(OPENING,2000).
-define(OPEN,5000).
-define(CLOSING,2000).


start()->
    register(doors,spawn(cdoors,loop_doors,[self()])).

open(Pis)->
    doors!{open,Pis}.   
close(Pis)->
    doors!{close,Pis}.
kill()->
    doors!kill.

opening(Pis,Pid,T,R)->
    case T==R of
	true ->
	    %si se han abierto las puertas
	    ascensor:doors_open(Pis),
	    io:format("ABIERTo~n"),
	    loop_opening(Pis,Pid,0,?OPEN);
	false ->
	    receive
		%si cerramos las puertas mientras se abren 
		{close,Pis} ->
		    io:format("lala~n"),
		    close(Pis,Pid,0,T);
		kill ->
		    exit(normal)
	    after
		50 ->
		    
		    opening(Pis,Pid,T+50,R)
	    end
    end.

loop_opening(Pis,Pid,T,R)->
    case T==R of
	true->
	    close(Pis,Pid,0,?CLOSING);
	false->
	    receive 
		{close,Pis} ->
		    io:format("Closing doors ~n"),
		    io:format("cerrando~n"),
		    close(Pis,Pid,0,?CLOSING);
		kill ->
		    exit(normal)
	    after 
		50 ->
		    
		    loop_opening(Pis,Pid,T+50,R)
	    end
    end.	


close(Pis,Pid,T,R) ->
    case T==R of
	true ->
	    ascensor:doors_closed(Pis),
	    loop_doors(Pid);
	    
	false ->
	    receive
		{open,Pis} ->
		    io:format("lalo~n"),
		    opening(Pis,Pid,0,T);
		kill ->
		    exit(normal)
	    after
		50 ->
		    bppool:display(Pis,"CLOSING"),
		    close(Pis,Pid,T+50,R)
	    end
    end.


loop_doors(Pid)->
    receive 
	{open,Pis} ->
	    io:format("Abriendo~n"),
	    opening(Pis,Pid,0,?OPENING);
	    
	{close,Pis} ->
	    close(Pis,Pid,0,?CLOSING);
	kill ->
	    exit(normal)
    end.
	


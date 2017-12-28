-module(p14).
-export([funcio/3, makeparser/1]).


funcio(_,[],1) ->
    true;
funcio(_,[],0) ->
    false;
funcio(_,[],undef) ->
    false;

funcio(F,[H|T],Estat) ->
    funcio(F,T,F(Estat,H)).

makeparser(Fun)->
    fun (Llista) ->
	    funcio(Fun,Llista,0)
		end.

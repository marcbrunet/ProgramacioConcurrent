-module(p13).
-export([funcio/3]).

funcio(_,[],Estat) ->
    Estat;
funcio(F,[H|T],Estat) ->
    funcio(F,T,F(Estat,H)).


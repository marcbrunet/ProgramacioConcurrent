-module(e21).
-export([fold/3]).

fold([],_,I) ->
    I;
fold([H|T],F,I) ->
    fold(T,F,F(H,I)).

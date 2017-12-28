-module(e22a).
-export([sumap/1, sumaparells/1]).

sumap([])->
    [];
sumap(L) ->
    sumaparells(lists:filter(fun(X)->X rem 2 == 0 end, L)).

sumaparells([])->
    0;
sumaparells([H|T]) ->
    H+sumaparells(T).

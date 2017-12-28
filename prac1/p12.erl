-module(p12).
-export([start/0, matching/2, buida/0, empila/2, desempila/1, cim/1]).


buida()-> [].

empila(Llista,E) ->
    [E|Llista].

desempila([_|Llista]) -> 
    Llista.

cim([Primer|_]) ->
    Primer.



start()->
    {_,LL,_}=io:scan_erl_exprs("expressio: "),
    matching(LL, buida()).


matching([{'dot',_}|_],Stack) ->
    cim(Stack);
matching([{_,_,E}|T],Stack) ->
    matching(T,empila(Stack,E));
matching([{'+',_}|T],Stack) ->
    Primer = cim(Stack),
    Segon = cim(desempila(Stack)),
    matching(T,empila(Stack,Primer+Segon));
matching([{'*',_}|T],Stack) ->
    Primer = cim(Stack),
    Segon = cim(desempila(Stack)),
    matching(T,empila(Stack,Primer*Segon)).





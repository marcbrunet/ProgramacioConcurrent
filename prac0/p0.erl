-module(p0).
-compile(export_all).

%2.1
compta([]) -> 0; %definicions es finalitza amb ;
compta([_|L]) -> 1+compta(L). %sentencies es finalitzen amb .

suprimeix([],_)->[];
suprimeix(L,E) ->[Llista || Llista <-L, Llista/=E]. % /= es diferent, || comprehension list

suprv2([],_)-> [];
suprv2([L|Resta],E) when E /=L ->
    [L] ++ suprv2(Resta,E);
suprv2([_|Resta],E) -> suprv2(Resta,E).

%2.2

buida(_)-> [].

empila(Llista,E) ->
    [E|Llista].

desempila([_|Llista]) -> 
    Llista.

cim([Primer|_]) ->
    Primer.

%2.3

preu(_,[])->
    -1;
preu(Id,[{Id_producte,_,Preu}|Resta]) -> if Id_producte =:= Id ->
						 Preu;
					    true -> preu(Id,Resta) end.
quantitat(Id,[{Id_producte,Quantitat,_}|Resta])->
    if Id_producte =:= Id ->
	    Quantitat;
       true -> quantitat(Id,Resta) end.



mostrar_prod([],_)-> 
    {};
mostrar_prod([{Id,Q,P}|_],Id) -> 
    {Id,Q,P};
mostrar_prod([_,_,_|R],Id) -> mostrar_prod(R,Id). 

treure_Prod([],_)->
    [];
treure_Prod([{Id,_,_}|A], {Id,_,_}) -> A;
treure_Prod([{Id,Q,P}|A], {Id2,_,_}) -> [{Id,Q,P}] ++ treure_Prod(A,{Id2,Q,P}). 

nou_Prod([],A)->
    [A];
nou_Prod([{Id,Q,P}|A], {Id,Q2,_}) when (Q2 < 0) and (Q-abs(Q2)<0) -> treure_Prod(A,{Id,Q2,P});
nou_Prod([{Id,Q,P}|A], {Id,Q2,_}) -> [{Id,Q+Q2,P}] ++ A;
nou_Prod([{Id,Q,P}|A], {Id2,Q2,P2}) -> [{Id,Q,P}] ++ nou_Prod(A,{Id2,Q2,P2}). 


venta([],_) -> [{}];
venta([{Id,Q,_}|A],Id) when Q =:= 1 -> 
    A;
venta([{Id,Q,P}|A],Id)->
    [{Id,Q-1,P}]++A;
venta([{Id,Q,P}|A],Id2)->
    [{Id,Q,P}] ++ venta(A,Id2).


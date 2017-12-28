-module(ex22).
-export([sumalista/1, sumaparell/1, sumapossenar/1, filtra/2, duplica/1, predicat/1]).

%exe22.1
sumaparell([])-> 0;
sumaparell(L)-> sumalista(lists:filter(fun(X)-> X rem 2 ==0 end,L)).

sumalista([])-> 0;
sumalista([H|T])-> H+sumalista(T).


%exe 22.2 suma posicion senar.
sumapossenar([])-> 0;
sumapossenar(L)-> sumalista(filtra(L,0)).

filtra([],_)->[];
filtra([_|L],I) 
	when I rem 2 ==0 -> filtra(L,I+1);
filtra([H|L],I)
	when I rem 2 /=0 -> [H]++filtra(L,I+1).

% exe 22.3 -> duplica los elementos parell de la lista original

duplica([])-> 0;
duplica(L)-> Parells=lists:filter(fun(T)-> T rem 2 ==0 end ,L),
	     Final=Parells++L,
	     lists:sort(Final).
%exe 22.4 -> cert si hiha un negatiu.

predicat([])->[];
predicat(L) ->lists:any(fun(X)-> X < 0 end,L).
    

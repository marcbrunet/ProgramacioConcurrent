-module(prac121).
-export([xenx/2]).

%L=[a,b,c,d,e,f,g,h,i].
% xenx(L,3).
%[a,d,g]

xenx(T,X)-> xenx(T,X,0).
xenx([],_,_)->[];
xenx([H|T],X,I) when I rem X == 0->
	[H]++xenx(T,X,I+1);
xenx([H|T],X,I) when I rem X /= 0 ->
	xenx(T,X,I+1).
%xenx([H|_],0)->[H];	
%xenx([H|T],Lon)->
%	A=lists:sublist(T,Lon,length(T)),
%	[H]++xenx(lists:sublist(T,Lon,length(T)),Lon).
-module(e1).
-compile(bots).
-export([ascensor/0]).

ascensor() ->
	%bots:start(),
	B=bots:nou(10,self()),
	start(B).

start(B) ->
	receive
		{clicked, N} -> encen(N,B), pregunta(N,B), start(B);
		abort -> B!close end.

encen(10,B) -> B!{light_on,10};
encen(N,B) -> B!{light_on,N}, encen(N+1,B).

pregunta(N,B) -> 
	receive 
		{clicked, Pis} -> if Pis >= N -> apaga(N,B); Pis<N -> pregunta(N,B) end;
		abort -> B!close end.

apaga(10,B) -> B!{light_off,10};
apaga(N,B) -> B!{light_off,N}, apaga(N+1,B).




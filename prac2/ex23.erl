-module(ex23).
-export([pescalar/2, rpc/3,loop/3,pe/2]).


pescalar([],[])->
    0;
pescalar([A|T1],[B|T2]) ->
    A*B + pescalar(T1,T2).


rpc(L1,L2,Pid)->
    Pid!{self(),L1,L2},
    receive
	{Pid,Response} ->
	    Response
    end.

start()->
    spawn(ex23,loop,[self(),,]).

%proces
loop(Pid,L1,L2)->
	Pid!{self(),pescalar(L1,L2)}.

pe(L1,L2)->
    {L11,L12}=lists:split(trunc(length(L1) div 2),L1),
    {L21,L22}=lists:split(trunc(length(L2) div 2),L2),
    P1 = spawn(ex23,loop,[self(),L11,L21]),
    P2 = spawn(ex23,loop,[self(),L12,L22]),
    rpc(L11,L21,P1)+rpc(L12,L22,P2).



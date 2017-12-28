-module(ex24).
-export([rpc/2,loop/0,pe/1]).


rpc(L1,Pid)->
    Pid!{self(),L1},
    receive
	{Pid,Response} ->
	    Response
    end.


%proces
loop(Pid,L1)->
    Pid!{self(),lists:sort(L1)}.


pe(L1)->
    {L11,L12}=lists:split(trunc(length(L1) div 2),L1),
    P1=spawn(?MODULE,loop,[self(),L11]),
    P2=spawn(?MODULE,loop,[self(),L12]),

    lists:merge(rpc(L11,P1),rpc(L12,P2)).


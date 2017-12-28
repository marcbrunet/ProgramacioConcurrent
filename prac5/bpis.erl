%%% @author Sebas Vila <sebas@bubinga.upc.es>
%%% @copyright (C) 2012, Sebas Vila
%%% @doc
%%% Botoneres de pis. Té display i polsadors per
%%% sol·licitar ascensor per pujar o baixar.
%%% @end
%%% Created :  8 Oct 2012 by Sebas Vila <sebas@bubinga.upc.es>
-module(bpis).
-include_lib("wx/include/wx.hrl").
-export([new/1,bpis_proc/1,display/2,set_light/3, kill/1]).

-define(BUTTON_UP,   300).
-define(BUTTON_DOWN, 301).
-define(UNACTIVE_COLOR, {246,246,245}).
-define(ACTIVE_COLOR, {255,255,153}).


%% Funcions públiques

new(Pis) ->
    spawn(?MODULE, bpis_proc, [Pis]).

display(Pid,M) ->
    Pid!{display,M}.

set_light(Pid, Dir, on) ->
    Pid!{light_on, Dir};
set_light(Pid, Dir, off) ->
    Pid!{light_off, Dir}.

kill(Pid) ->
    Pid!kill.

%% -------------------------------

bpis_proc(Pis) ->
    wx:set_env(wxenv:get()),
    Frame = create_window(Pis),
    L = create_widgets(Frame),
    wxWindow:show(Frame),
    loop(Pis, Frame, L),
    ok.

create_window(Pis) ->
    Title   = io_lib:format("Pis ~b",[Pis]),
    Frame = wxFrame:new(wx:null(), -1, Title),
    wxFrame:connect(Frame, close_window),
    Frame.

create_widgets(Panel) ->
    % Create the sizer
    Sz = wxBoxSizer:new(?wxVERTICAL),
    SzFlags = [{proportion, 0}, {border, 4}, {flag, ?wxALL}],

    % Create the display and add it to sizer
    Display = wxTextCtrl:new(Panel, 100, 
			     [{style,?wxTE_READONLY bor ?wxTE_RIGHT},
			      {value, "0"}]),
    Redtext = wxTextAttr:new({255,10,10}),
    wxTextCtrl:setDefaultStyle(Display, Redtext),
    wxSizer:add(Sz,Display,SzFlags),

    % Create open/close doors buttons
    UpB = wxButton:new(Panel, ?BUTTON_UP, [{label,"\x{2191}"}]),
    wxButton:setToolTip(UpB, "Puja"),
    DownB = wxButton:new(Panel, ?BUTTON_DOWN, [{label,"\x{2193}"}]),
    wxButton:setToolTip(DownB, "Baixa"),
    wxSizer:add(Sz,UpB, SzFlags),
    wxSizer:add(Sz,DownB,SzFlags),
    wxButton:setBackgroundColour(UpB, ?UNACTIVE_COLOR),
    wxButton:setBackgroundColour(DownB, ?UNACTIVE_COLOR),
    wxButton:connect(UpB, command_button_clicked),
    wxButton:connect(DownB, command_button_clicked),

    % fits the window to the childs
    wxSizer:layout(Sz),
    wxSizer:fit(Sz,Panel),
    {Display, UpB, DownB}.


loop(Pis, Frame, W) ->
    {Display, UpB, DownB} = W,
    receive 
   	#wx{event=#wxClose{}} ->
   	    io:format("Closing bpis ~b ~n",[Pis]),
	    wxWindow:destroy(Frame),
	    ascensor:abort(),
	    ok;
   	#wx{id=?BUTTON_UP,
	    event=#wxCommand{type=command_button_clicked}} ->
	    ascensor:pbp_pushed(Pis, up),  %%%
	    loop(Pis, Frame, W);
   	#wx{id=?BUTTON_DOWN,
	    event=#wxCommand{type=command_button_clicked}} ->
	    ascensor:pbp_pushed(Pis, down), %%%
	    loop(Pis, Frame, W);
 	kill -> 
	    wxWindow:destroy(Frame),
	    ok;
	{light_on, F} ->
	    B = if F =:= up -> UpB; F =:= down -> DownB end,
	    wxButton:setBackgroundColour(B, ?ACTIVE_COLOR),
	    loop(Pis, Frame, W);
	{light_off, F} ->
	    B = if F == up -> UpB; F == down -> DownB end,
	    wxButton:setBackgroundColour(B, ?UNACTIVE_COLOR),
	    loop(Pis, Frame, W);
	{display, off} ->
	    % switch off the display
	    wxTextCtrl:clear(Display),
	    loop(Pis, Frame, W);
	{display, V} when is_integer(V) ->
	    % show V in the display
	    T = io_lib:format("~B",[V]),
	    wxTextCtrl:clear(Display),
	    wxTextCtrl:setValue(Display,T),
	    loop(Pis, Frame, W);
	{display, L} when is_list(L) ->
	    % show V in the display
	    T = io_lib:format("~6s",[L]),
	    wxTextCtrl:clear(Display),
	    wxTextCtrl:setValue(Display,T),
	    loop(Pis, Frame, W);
	Msg ->
	    io:format("Botonera pis got unknown message ~p ~n", [Msg]),
	    loop(Pis, Frame, W)
    end.



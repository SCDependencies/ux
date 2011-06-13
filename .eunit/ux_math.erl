% vim: set filetype=erlang shiftwidth=4 tabstop=4 expandtab tw=80:
%%% =====================================================================
%%% This library is free software; you can redistribute it and/or modify
%%% it under the terms of the GNU Lesser General Public License as
%%% published by the Free Software Foundation; either version 2 of the
%%% License, or (at your option) any later version.
%%%
%%% This library is distributed in the hope that it will be useful, but
%%% WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
%%% Lesser General Public License for more details.
%%%
%%% You should have received a copy of the GNU Lesser General Public
%%% License along with this library; if not, write to the Free Software
%%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
%%% USA
%%%
%%% $Id$
%%%
%%% @copyright 2010-2011 Michael Uvarov
%%% @author Michael Uvarov <freeakk@gmail.com>
%%% @see ux
%%% @end
%%% =====================================================================


-module(ux_math).
-author('Uvarov Michael <freeakk@gmail.com>').

-export([factorial/1]). % :)

% Statistics
-export([average/1]).     % http://en.wikipedia.org/wiki/Arithmetic_mean
%-export([expectation/1]). % http://en.wikipedia.org/wiki/Expected_value
-export([variance/1]).    % http://en.wikipedia.org/wiki/Variance 
-export([stdev/1]).       % http://en.wikipedia.org/wiki/Standard_deviation
-export([stdev_filter_miss/1]). 

-define(POW2(X), ((X) * (X))).

factorial(N) when N > 0, is_integer(N) -> factorial1(N, 1);
factorial(0) -> 1.
% @private
factorial1(0, X) -> 
    X;
factorial1(N, X)  -> 
    factorial1(N - 1, N * X).

average([X|Tail]) ->
    average1(Tail, X, 1).
% @private
average1([X|Tail], Sum, Count) ->
    average1(Tail, Sum + X, Count + 1);
average1([], Sum, Count) ->
    Sum / Count.

% Dispersion
variance([_|_] = X) ->
    variance1(X, average(X), 0, 0).
% @private
variance1([X|Tail], A, Sum, Count) ->
    Diff = X - A,
    variance1(Tail, A, Sum + ?POW2(Diff), Count + 1);
variance1([], _, Sum, Count) -> Sum / Count.


stdev([_,_|_] = X) ->
    stdev1(X, average(X), 0, 0).
%% @private
stdev1([X|Tail], A, Sum, Count) ->
    Diff = X - A,
    stdev1(Tail, A, Sum + ?POW2(Diff), Count + 1);
stdev1([], _, Sum, Count) -> math:sqrt(Sum / (Count - 1)).

%% Delete all misses from a list using 3-sigma (3-standard error) rule.
stdev_filter_miss(Val) ->
    stdev_filter_miss1(Val, 3*stdev(Val), average(Val), [], [], true). % 3-sigma rule
%% Parameters:
%% Input list
%% Sigma - 3-sigma
%% Avg   - Average
%% Res   - Values in diapozone
%% Misses
%% Flag  - Exit flag (if true then return result)
%% Returns: {Res, Misses}
stdev_filter_miss1([H|T], Sigma3, Avg, Res, Misses, Flag) ->
    case erlang:abs(H - Avg) >= Sigma3 of
        true ->  stdev_filter_miss1(T, Sigma3, Avg, Res, [H|Misses], false);
        false -> stdev_filter_miss1(T, Sigma3, Avg, [H|Res], Misses, Flag)
    end;
% No more misses.
stdev_filter_miss1([], _Sigma3, _Avg, Res, Misses, true) ->
    {lists:reverse(Res), lists:reverse(Misses)};
stdev_filter_miss1([], Sigma3, Avg, Res, Misses, false) ->
    stdev_filter_miss1(lists:reverse(Res), Sigma3, Avg, [], Misses, true).
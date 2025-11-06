% COMMANDS TO RUN:
% clingo instance.lp hanoi_tower.lp 0 --stats
% python control.py

#const moves = 70.                               % maximum number of disk moves

time(1..moves).              % time points of disk moves are limited by 'moves'

on(D,P,0) :- init_on(D,P).                                      % initial state

{move(D,P,T) : disk(D), peg(P)} = 1 :- time(T).       % one move per time point

moved(D,T) :- move(D,P,T).                                     % the moved disk

blocked(D,P,T) :- on(D,P,T-1), time(T).                    % disk D on P at T-1
blocked(D,P,T) :- blocked(D+1,P,T), disk(D).  % smaller disk than D on P at T-1

:- move(D,P,T), blocked(D,P,T).  % do not move a disk inside (or back on) tower
:- moved(D,T), on(D,P,T-1), blocked(D+1,P,T). % only top-most disk can be moved

on(D,P,T) :- move(D,P,T).                                         % move effect
on(D,P,T) :- on(D,P,T-1), time(T), not moved(D,T).              % unmoved disks

:- disk(D), time(T), #count{P : on(D,P,T)} != 1. % (redundant) state constraint

:- goal_on(D,P), not on(D,P,moves). % check goal at the last time point 'moves'

#show move/3.                     % display (only) the atoms representing moves

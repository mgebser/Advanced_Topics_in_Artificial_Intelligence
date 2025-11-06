% COMMANDS TO RUN:
% clingo instance.lp hanoi_tower.lp 0 --stats
% python control.sol.py

% #const moves = 70.                               % maximum number of disk moves

% time(1..moves).              % time points of disk moves are limited by 'moves'

on(D,P,0) :- init_on(D,P).                                      % initial state


#program goal(moves).

#external last(moves).

:- goal_on(D,P), not on(D,P,moves), last(moves).


#program action(time).

{move(D,P,time) : disk(D), peg(P)} = 1.       % one move per time point

moved(D,time) :- move(D,P,time).                                     % the moved disk

blocked(D,P,time) :- on(D,P,time-1).                    % disk D on P at T-1
blocked(D,P,time) :- blocked(D+1,P,time), disk(D).  % smaller disk than D on P at T-1

:- move(D,P,time), blocked(D,P,time).  % do not move a disk inside (or back on) tower
:- moved(D,time), on(D,P,time-1), blocked(D+1,P,time). % only top-most disk can be moved

on(D,P,time) :- move(D,P,time).                                         % move effect
on(D,P,time) :- on(D,P,time-1), not moved(D,time).              % unmoved disks

:- disk(D), #count{P : on(D,P,time)} != 1. % (redundant) state constraint


#show move/3.                     % display (only) the atoms representing moves

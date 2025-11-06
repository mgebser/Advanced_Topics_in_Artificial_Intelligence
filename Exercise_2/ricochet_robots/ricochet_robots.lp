% COMMANDS TO RUN:
% python control.py

% DOMAIN: Auxiliary constants and predicates on available targets and obstacles

% Maximum number of robot moves
#const moves = 25.

% Time points of robot moves are limited by 'moves'
time(1..moves).

% Color of a target and of robot to move there (other colors: blue, green, red)
#const color = yellow.

% Motif of a target (other motifs: saturn, star, sun)
#const motif = moon.

% Color and motif yield target position for a robot
% target(color,X,Y) :- available_target(color,motif,X,Y).

% Neighboring positions are adjacent in either horizontal or vertical direction
dir(-1,0;1,0;0,-1;0,1).

% Robot moves in some direction stop at barriers or borders as static obstacles
stop(X   ,Y   , DX, DY) :- barrier(X,Y,DX,DY).
stop(X+DX,Y+DY,-DX,-DY) :- barrier(X,Y,DX,DY).
stop(X   ,Y,    DX,  0) :- dim(X), dim(Y), dir(DX,0), not dim(X+DX).
stop(X   ,Y,     0, DY) :- dim(X), dim(Y), dir(0,DY), not dim(Y+DY).

% GENERATE + DEFINE + TEST: Choose robot moves, update positions, end at target

% Robots start from initial positions
% pos(R,X,Y,0) :- initial_pos(R,X,Y).

% Target must be reached after at most 'moves' many robot moves
:- target(R,X,Y), not pos(R,X,Y,moves).

% Target has not been reached before the T-th robot move
todo(T) :- target(R,X,Y), time(T), not pos(R,X,Y,T-1).

% Move exactly one robot in some direction if the target is not already reached
{move(R,DX,DY,T) : robot(R), dir(DX,DY); not todo(T)} = 1 :- time(T).

% Robot moves in some direction stop at (other) robots as dynamic obstacles
stop(X-DX,Y-DY,DX,DY,T) :- pos(R,X,Y,T-1), time(T), dir(DX,DY),
                           not stop(X,Y,-DX,-DY).

% Robots will traverse the path in some direction until stopping at an obstacle
path(R,X   ,Y   ,DX,DY,T) :- pos(R,X,Y,T-1), time(T), dir(DX,DY).
path(R,X+DX,Y+DY,DX,DY,T) :- path(R,X,Y,DX,DY,T),
                             not stop(X,Y,DX,DY),
                             not stop(X,Y,DX,DY,T).

% A robot that does not move keeps its position
pos(R,X,Y,T) :- pos(R,X,Y,T-1), time(T), not move(R,_,_,T).

% A robot that moves in some direction changes to position where its path stops
pos(R,X,Y,T) :- move(R,DX,DY,T), path(R,X,Y,DX,DY,T), not path(R,X+DX,Y+DY,DX,DY,T), not pos(R,X,Y,T-1).

% Each robot has exactly one position at any point of time (state constraint)
:- robot(R), time(T), #count{X,Y : pos(R,X,Y,T)} != 1.

% OPTIMIZE: Target should be reached with as few robot moves as possible

% Each robot move is penalized
:~ todo(T). [1,T]

% DISPLAY: Output the robot moves (only) in a user-friendly format

#show.
#show move(R, left,T) : move(R,-1, 0,T).
#show move(R,right,T) : move(R, 1, 0,T).
#show move(R,   up,T) : move(R, 0,-1,T).
#show move(R, down,T) : move(R, 0, 1,T).
% #show pos/4.

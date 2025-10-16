% COMMANDS TO RUN:
% clingo graph_01.lp longest_path.lp --stats
% clingo graph_01.lp longest_path.lp --stats --opt-strategy=usc
% clingo graph_02.lp longest_path.lp --stats
% clingo graph_02.lp longest_path.lp --stats --opt-strategy=usc
% clingo graph_03.lp longest_path.lp --stats
% clingo graph_03.lp longest_path.lp --stats --opt-strategy=usc

% GENERATE: Choose directed (weighted) edges for a simple (cycle-free) path

% At most one outgoing edge per node can be on the path
{path(X,Y) : edge(X,Y,W)} 1 :- node(X).

% At most one incoming edge per node can be on the path
{path(X,Y) : edge(X,Y,W)} 1 :- node(Y).

% DEFINE + TEST: Chosen edges must form a single (simple) path

% Nodes that have an outgoing edge
outgoing(X) :- path(X,Y).

% Nodes that have an incoming edge
incoming(Y) :- path(X,Y).

% First node(s) of some path
first(X) :- outgoing(X), not incoming(X).
#show first/1.

% Final node(s) of some path
final(Y) :- incoming(Y), not outgoing(Y).
% #show final/1.

% There can be at most one first node
:- #count{X : first(X)} != 1.

% There can be at most one final node
:- #count{X : final(X)} != 1.

% Chosen edges must not form any cycle(s)
reached(X) :- node(X), not incoming(X).
reached(Y) :- reached(X), path(X,Y).

:- node(Y), not reached(Y).
% #show reached/1.

% OPTIMIZE: Maximize accumulated edge weights of simple path

% Each edge on simple path is rewarded by its weight
:~ path(X,Y), edge(X,Y,C). [-C,X]

% DISPLAY: Output the edges of simple path (only)

#show path/2.

% path(1,3) path(2,4) path(3,5) path(4,1) path(5,2)
% 2 -> 4 -> 1 -> 3 -> 5 -> 2 -> ...
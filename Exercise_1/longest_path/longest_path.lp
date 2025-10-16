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
% ! TODO !

% DEFINE + TEST: Chosen edges must form a single (simple) path

% Nodes that have an outgoing edge
outgoing(X) :- path(X,Y).

% Nodes that have an incoming edge
incoming(Y) :- path(X,Y).

% First node(s) of some path
% ! TODO !

% Final node(s) of some path
% ! TODO !

% There can be at most one first node
:- #count{X : first(X)} > 1.

% There can be at most one final node
% ! TODO !

% Chosen edges must not form any cycle(s)
% ! TODO !

% OPTIMIZE: Maximize accumulated edge weights of simple path

% Each edge on simple path is rewarded by its weight
% ! TODO !

% DISPLAY: Output the edges of simple path (only)

#show path/2.

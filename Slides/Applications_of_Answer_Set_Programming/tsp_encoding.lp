% COMMANDS TO RUN:
% clingo tsp_instance.lp tsp_encoding.lp --text
% clingo tsp_instance.lp tsp_encoding.lp
% clingo tsp_instance.lp tsp_encoding.lp --opt-strategy=usc

% GENERATE: Precisely one outgoing and incoming edge per node

{cycle(X,Y): edge(X,Y,C)} = 1 :- node(X).
{cycle(X,Y): edge(X,Y,C)} = 1 :- node(Y).

% DEFINE + TEST: Each node must be reached from starting node

reached(X) :- X = #min{Y: node(Y)}.
reached(Y) :- reached(X), cycle(X,Y).

:- node(Y), not reached(Y).

% OPTIMIZE: Minimize accumulated edge costs of round trip

:~ cycle(X,Y), edge(X,Y,C). [C,X]
% #minimize{C,X : cycle(X,Y), edge(X,Y,C)}.

% DISPLAY: Output the edges of round trip (only)

#show cycle/2.

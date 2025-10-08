% COMMANDS TO RUN:
% clingo modeling_language.lp --text
% clingo modeling_language.lp

% Fact(s)
p(0).

% Normal rule(s)
p(1) :- p(0).

% Choice rule(s)
{p(2); p(3)} = 1 :- p(1).

% Integrity constraint(s)
:- p(3).

% Default negation
:- not p(2).

% First-order variables
q(X) :- p(X).

% Arithmetics
r(X+1) :- p(X).

% Conjunction(s)
s(X) :- q(X), r(X).

% Aggregate(s)
t(N) :- #sum{X : s(X)} = N.

% t(N) :-  #sum+{X : s(X)} = N.
% t(N) :- #count{X : s(X)} = N.
% t(N) :-   #min{X : s(X)} = N.
% t(N) :-   #max{X : s(X)} = N.

% Conditional literal(s)
{u(X) : r(X), X < N} :- t(N).

% Multi-criteria Optimization
:~ u(X). [X@1]
:~ #count{X : u(X)} = 0. [1@2]

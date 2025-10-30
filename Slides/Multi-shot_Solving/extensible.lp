% COMMANDS TO RUN:
% python extensible.py

{g(1)}.

#program extensible.
#external e(X) : f(X), g(X).
f(1). f(2).
a(X) :- f(X), e(X).
b(X) :- f(X), not e(X).

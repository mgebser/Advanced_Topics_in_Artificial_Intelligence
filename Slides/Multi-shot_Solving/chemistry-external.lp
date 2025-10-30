% COMMANDS TO RUN:
% python control-external.py
% clingo control-external.lp chemistry-external.lp
% clingo control-external.lp chemistry-external.lp --output-debug=text

a(1).

#program acid(k).
b(k).
c(X,k) :- a(X).

#program base.
a(2).

#program acid(k).
#external d(X,k) : c(X,k).
e(X,k) :- d(X,k).

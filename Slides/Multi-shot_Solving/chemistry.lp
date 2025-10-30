% COMMANDS TO RUN:
% python control-base.py
% python control-acid.py
% clingo control-base.lp chemistry.lp
% clingo control-acid.lp chemistry.lp

a(1).

#program acid(k).
b(k).
c(X,k) :- a(X).

#program base.
a(2).

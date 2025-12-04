% Choose one machine per operation

{process(X,M,P) : mode(X,M,P)} = 1 :- operation(X,J,N).

% Operations (of distinct jobs) on same machine have to be ordered

ordered(X,Y) :- operation(X,J1,N1), process(X,M,P1),
                operation(Y,J2,N2), process(Y,M,P2), J1 < J2.

% Choose an order of processing two operations on the same machine

{order(X,Y)} :- ordered(X,Y).
 order(Y,X)  :- ordered(X,Y), not order(X,Y).

% Derive lower bounds on operation start times

&diff{     0 - start(X)} <= 0 :- operation(X,J,1).
&diff{end(X) - start(Y)} <= 0 :- order(X,Y).
&diff{end(X) - start(Y)} <= 0 :- operation(X,J,N), operation(Y,J,N+1).

% Derive lower bounds on operation end times

&diff{start(X) - end(X)} <= -P :- process(X,_,P).

% Restrict lower bounds on start times to range given by time predicate

&diff{start(X) - 0} <= S :- operation(X,J,N), not operation(X+1,J,N+1),
                            time(S), not time(S+1).

% Minimize number of delayed jobs

:~ operation(X,J,N), not operation(X+1,J,N+1),
   deadline(J,D), not &diff{end(X) - 0} <= D. [1,J]

% Output scheduled machines (and the variable assignment)

#show process/3.

%*
  $ clingo-dl instance.lp deadline.lp differences.lp --stats
  $ clingo-dl instance.lp deadline.lp differences.lp --stats --const latest=1000
*%

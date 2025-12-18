% COMMAND TO RUN:
% python control.py

% Impose makespan smaller than bound 'h'

#program horizon(h).

#external bound(h).

&diff{makespan - 0} <= h-1 :- not bound(h).

% Minimize sum of job delays (w.r.t. the optimal bound 'h' on makespan)

#program delays(h).

bound(h).

delay(X,D,0..h-D-1) :- operation(X,J,N), not operation(X+1,J,N+1),
                       deadline(J,D).

delayed(X,D,T) :- delay(X,D,T), not &diff{end(X) - 0} <= D+T.

:~ delayed(X,D,T). [1,X,T]

% Output the delays of jobs' last operations

#show delayed(X,D,T) : delayed(X,D,T-1), not delayed(X,D,T).
#show delayed(X,D,0) : operation(X,J,N), not operation(X+1,J,N+1),
                       deadline(J,D), not delayed(X,D,0).

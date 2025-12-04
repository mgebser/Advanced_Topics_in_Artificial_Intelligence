% Choose one machine per operation

{process(X,M,P) : mode(X,M,P)} = 1 :- operation(X,J,N).

% Operations (of distinct jobs) on same machine have to be ordered

ordered(X,Y) :- operation(X,J1,N1), process(X,M,P1),
                operation(Y,J2,N2), process(Y,M,P2), J1 < J2.

% Choose an order of processing two operations on the same machine

{order(X,Y)} :- ordered(X,Y).
 order(Y,X)  :- ordered(X,Y), not order(X,Y).

% Derive lower bounds on operation start times

start(X,0) :- operation(X,J,1).
start(Y,E) :- end(X,E), order(X,Y).
start(Y,E) :- end(X,E), operation(X,J,N), operation(Y,J,N+1).

% Derive lower bounds on operation end times

end(X,S+P) :- start(X,S), process(X,_,P), time(S).

% Restrict lower bounds on start times to range given by time predicate

:- start(X,S), not time(S).

% Derive processing interval and minimize the makespan

makespan(K) :- end(X,K), operation(X,J,N), not operation(X+1,J,N+1).
makespan(K) :- makespan(K+1), 0 < K.

:~ makespan(K). [1,K]

% Output scheduled machines and start times

#show process/3.
#show start/2.

%*
  $ clingo instance.lp compact.lp --stats
  $ clingo instance.lp compact.lp --stats --const latest=5000
*%

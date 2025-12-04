% Choose one machine per operation

{process(X,M,P) : mode(X,M,P)} = 1 :- operation(X,J,N).

% Operations (of distinct jobs) on same machine have to be ordered

ordered(X,Y) :- operation(X,J1,N1), process(X,M,P1),
                operation(Y,J2,N2), process(Y,M,P2), J1 != J2.

% Choose the operation start times

{start(X,S) : time(S)} = 1 :- operation(X,J,N).

% Derive the operation end times

end(X,S+P) :- start(X,S), process(X,_,P).

% Operations (of distinct jobs) must be processed without overlaps

:- ordered(X,Y), start(X,S1), start(Y,S2), end(X,E1), S1 <= S2, S2 < E1.

% Successor operation must not start before end of its predecessor

:- operation(X,J,N), operation(Y,J,N+1), start(Y,S), end(X,E), S < E.

% Derive and minimize the makespan

makespan(K) :- K = #max{E : end(X,E),
                            operation(X,J,N), not operation(X+1,J,N+1)}.

:~ makespan(K). [K]

% Output scheduled machines and start times

#show process/3.
#show start/2.

%*
  $ clingo instance.lp vanilla.lp --stats
*%

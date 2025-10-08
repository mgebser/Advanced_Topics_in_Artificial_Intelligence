% COMMANDS TO RUN:
% clingo lpc_instance.lp lpc_encoding.lp --text
% clingo lpc_instance.lp lpc_encoding.lp --stats
% clingo lpc_instance.lp lpc_encoding.lp --stats --opt-strategy=usc
% clingo lpc_instance_large.lp lpc_encoding.lp --stats --opt-strategy=usc
% clingo lpc_instance_large.lp lpc_encoding.lp --stats --quiet=1,0

% GENERATE: Any package may be installed

{install(P,V)} :- package(P,V).

% DEFINE + TEST: Package conflicts, dependencies, and requests must be satisfied

exclude(C) :- install(P,V), conflicts(P,V,C).
include(C) :- install(P,V), depends(P,V,C).
satisfy(C) :- install(P,V), satisfies(P,V,C).

:- exclude(C), satisfy(C).
:- include(C), not satisfy(C).
:- request(C), not satisfy(C).

% OPTIMIZE: Minimize new packages, deletions, and/or changes

install(P)   :- install(P,V).
installed(P) :- installed(P,V).

violate(newpkg,L,P) :- utility(newpkg,L), install(P), not installed(P).
violate(delete,L,P) :- utility(delete,L), installed(P), not install(P).
violate(change,L,P) :- utility(change,L), installed(P,V), not install(P,V).
violate(change,L,P) :- utility(change,L), install(P,V), not installed(P,V).

:~ violate(U,L,T). [1@L,U,T]
% #minimize{1@L,U,T : violate(U,L,T)}.

% DISPLAY: Output the packages to install (only)

#show install/2.

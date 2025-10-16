% COMMANDS TO RUN:
% clingo grid_01.lp grid_counter.lp --stats
% clingo grid_02.lp grid_counter.lp --stats
% clingo grid_03.lp grid_counter.lp --stats
% clingo grid_04.lp grid_counter.lp --stats
% clingo grid_05.lp grid_counter.lp --stats

% DOMAIN: Auxiliary predicates on possible increments and neighboring cells

% Possible occurrences of increment values per cell depend on difference to 9
inc(1..5).

poss(X,Y,I,1..C) :- cell(X,Y,N), inc(I), C = (9-N)/I.

% Neighboring cells are adjacent in either horizontal or vertical direction
dir(-1,0;1,0;0,-1;0,1).

% near(X1,Y1,X2,Y2) :- ! TODO !

% GENERATE: Choose the occurrences of increment values for each cell

% At most one number of occurrences per increment value and cell
% {counter(X,Y,I,C) : poss(X,Y,I,C)} 1 :- ! TODO !.

% TEST: Cell number, increment values, and neighbors' increments must add to 9

% #sum/#sum+ aggregate establishes that a cell's number plus increments equal 9
% :- cell(X,Y,N), ! TODO !.

% OPTIMIZE: Minimize the overall occurrences of increment values

% Each occurrence of an increment value for a cell is penalized
% ! TODO !

% DISPLAY: Output the occurrences of increment values (only)

#show counter/4.

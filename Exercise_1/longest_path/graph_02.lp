% COMMANDS TO RUN:
% clingo graph_02.lp longest_path.lp --stats
% clingo graph_02.lp longest_path.lp --stats --opt-strategy=usc

node(1..6).

edge(1,2,2). edge(1,3,3). edge(1,4,1).
edge(2,4,2). edge(2,5,2). edge(2,6,4).
edge(3,1,3). edge(3,4,2). edge(3,5,2).
edge(4,1,1). edge(4,2,2).
edge(5,3,2). edge(5,4,2). edge(5,6,1).
edge(6,2,4). edge(6,3,3). edge(6,5,1).

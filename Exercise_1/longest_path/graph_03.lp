% COMMANDS TO RUN:
% clingo graph_03.lp longest_path.lp --stats
% clingo graph_03.lp longest_path.lp --stats --opt-strategy=usc

node(1..8).

edge(1,2,4). edge(1,3,3). edge(1,4,2).
edge(2,3,3). edge(2,4,5). edge(2,5,3).
edge(3,1,7). edge(3,6,3). edge(3,7,2).
edge(4,3,3). edge(4,5,1). edge(4,6,3). edge(4,7,5).
edge(5,2,3). edge(5,4,5). edge(5,8,4).
edge(6,1,3). edge(6,5,4). edge(6,8,3).
edge(7,3,1). edge(7,4,2). edge(7,5,6).
edge(8,2,2). edge(8,3,1). edge(8,5,4). edge(8,7,2).

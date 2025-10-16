% COMMANDS TO RUN:
% clingo graph_01.lp longest_path.lp --stats
% clingo graph_01.lp longest_path.lp --stats --opt-strategy=usc

node(1..5).

edge(1,2,2). edge(1,3,4).
edge(2,1,3). edge(2,4,2). edge(2,5,3).
edge(3,3,2). edge(3,5,5).
edge(4,1,4). edge(4,3,1). edge(4,5,2).
edge(5,2,1). edge(5,3,2).

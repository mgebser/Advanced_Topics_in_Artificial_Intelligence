% COMMANDS TO RUN:
% clingo tsp_instance.lp tsp_encoding.lp --text
% clingo tsp_instance.lp tsp_encoding.lp
% clingo tsp_instance.lp tsp_encoding.lp --opt-strategy=usc

node(1..6).

edge(1,2,2). edge(1,3,3). edge(1,4,1).
edge(2,4,2). edge(2,5,2). edge(2,6,4).
edge(3,1,3). edge(3,4,2). edge(3,5,2).
edge(4,1,1). edge(4,2,2).
edge(5,3,2). edge(5,4,2). edge(5,6,1).
edge(6,2,4). edge(6,3,3). edge(6,5,1).

# Exercise 1

This exercise is about completing partial ASP encodings for three problems:

* [longest_path](./longest_path): Unlike computing a shortest path, which can be done in polynomial time, finding a [longest path](https://en.wikipedia.org/wiki/Longest_path_problem) in a directed (weighted) graph is an NP-hard optimization problem. Our goal is to complete the partial encoding given in [longest_path.lp](./longest_path/longest_path.lp) such that longest (simple) paths in directed weighted graphs can be computed by optimization with the ASP system [clingo](https://potassco.org/clingo/).

  The complete problem encoding developed during the course session on October 16 is available as [longest_path.sol.lp](./longest_path/longest_path.sol.lp).

* [grid_counter](./grid_counter): This problem is taken from the [LP/CP Programming Contest 2023](https://github.com/lpcp-contest/lpcp-contest-2023/tree/main/problem-2). It is a calculation puzzle on a grid, and our goal is to complete the partial encoding given in [grid_counter.lp](./grid_counter/grid_counter.lp).

  The complete problem encoding developed during the course session on October 16 is available as [grid_counter.sol.lp](./grid_counter/grid_counter.sol.lp).

* [ricochet_robots](./ricochet_robots): The board game [Ricochet Robots](https://en.wikipedia.org/wiki/Ricochet_Robots) is a challenging grid puzzle. It has already been investigated as a [benchmark problem for ASP systems](https://potassco.org/labs/ricochet/). The goal is to
complete the partial encoding given in [ricochet_robots.lp](./ricochet_robots/ricochet_robots.lp), where the Python script [visualize.py](./ricochet_robots/visualize.py) is an
adjusted version of the visualization script shipped with the [clingo examples](https://github.com/potassco/clingo/tree/master/examples/clingo/robots#a-ricochet-robots-solver).

  The complete problem encoding developed during the course session on October 23 is available as [ricochet_robots.sol.lp](./ricochet_robots/ricochet_robots.sol.lp).

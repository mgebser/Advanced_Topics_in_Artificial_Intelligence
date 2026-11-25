% COMMANDS TO RUN:
% clingo instance.lp hanoi_tower.lp 0 --stats
% python control.py

peg(a;b;c). % the pegs

disk(1..7). % the greater the number, the smaller the disk

    init_on(1,a).  init_on((2;7),b).  init_on((3;4;5;6),c).

goal_on((3;4),a).                   goal_on((1;2;5;6;7),c).

%*
                   7
      6            6
      5            5
    7 4   ->   4   2
  1 2 3        3   1
  a b c        a b c
*%

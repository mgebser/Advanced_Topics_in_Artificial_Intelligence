% - operation(OPERATION,JOB,POSITION): OPERATION belongs to JOB at POSITION
% - mode(OPERATION,MACHINE,PROC_TIME): OPERATION needs PROC_TIME on MACHINE
% - time(0..latest): latest time for starting jobs configurable by constant

operation(1,1,1).   mode(1,1,11).   mode(1,2,10).
operation(2,1,2).   mode(2,2,6).    mode(2,3,7).
operation(3,1,3).   mode(3,4,6).

operation(4,2,1).   mode(4,2,8).    mode(4,3,9).
operation(5,2,2).   mode(5,4,8).
operation(6,2,3).   mode(6,1,6).    mode(6,2,5).

operation(7,3,1).   mode(7,4,6).
operation(8,3,2).   mode(8,1,11).   mode(8,2,10).
operation(9,3,3).   mode(9,2,5).    mode(9,3,6).

operation(10,4,1).  mode(10,1,6).   mode(10,2,5).
operation(11,4,2).  mode(11,4,3).
operation(12,4,3).  mode(12,2,13).  mode(12,3,14).

#const latest = 50.
time(0..latest).

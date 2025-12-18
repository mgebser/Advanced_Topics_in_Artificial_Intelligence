#!/usr/bin/env python

# COMMAND TO RUN:
# python control.py

from clingo import Control, Number, Function
from clingo.ast import parse_files, ProgramBuilder # parsing DL atoms
from clingodl import ClingoDLTheory                # DL propagator

facts = ["instance.lp", "deadline.lp"]
encodings = ["difference.lp", "differencee.lp"]
call = 1
answer = 1
horizon = 0
previous = 0
progress = False

def on_model(m):
    global thy
    global answer
    global horizon

    # print shown atoms in answer set
    print("---------------------------")
    print("Answer: " + str(answer))
    for atom in m.symbols(shown=True): print(atom, end=" ")
    answer = answer+1

    # print assignment of DL variables
    print("\nAssignment:")
    for key, val in thy.assignment(m.thread_id):
        print(str(key) + "=" + str(val), end=" ")
        if key == Function("makespan", []): horizon = val

    # print optimization value (if any) and planning horizon
    if m.cost: print("\nOptimization: " + str(m.cost[0]), end="")
    print("\nHorizon: " + str(horizon))

# initialize control object and theory propagator
thy = ClingoDLTheory()
ctl = Control()
thy.register(ctl)

# read input facts and the encoding(s) with DL atoms
for data in facts: ctl.load(data)
with ProgramBuilder(ctl) as bld:
   parse_files(encodings, lambda ast: thy.rewrite_ast(ast, bld.add))

print("===========================")
print("CALL " + str(call))

# compute first answer set (if any)
ctl.ground([("base", [])])
thy.prepare(ctl)
ctl.solve(on_model = on_model)

# minimize the makespan in while loop
while horizon != previous:
    call = call+1
    answer = 1
    progress = True

    print("===========================")
    print("CALL " + str(call))

    # harden previous upper bound on makespan (if any)
    if previous:
        ctl.release_external(Function("bound", [Number(previous)]))
        if previous == horizon+1: progress = False
    previous = horizon

    # search for answer set with shorter makespan
    ctl.ground([("horizon", [Number(horizon)])])
    thy.prepare(ctl)
    ctl.solve(on_model = on_model)

print("UNSATISFIABLE")

# impose optimal makespan as hard upper bound
if progress:
    ctl.ground([("horizon", [Number(horizon+1)])])
    ctl.release_external(Function("bound", [Number(horizon+1)]))

# minimize job delays w.r.t. optimal makespan
if horizon:
    call = call+1
    answer = 1

    print("===========================")
    print("CALL " + str(call))

    ctl.ground([("delays", [Number(horizon)])])
    thy.prepare(ctl)
    ctl.solve(on_model = on_model)
    print("OPTIMUM FOUND")

print("===========================")

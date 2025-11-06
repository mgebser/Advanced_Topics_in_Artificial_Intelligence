#!/usr/bin/env python

# COMMANDS TO RUN:
# python control.sol.py

import clingo
# from clingo import Number, Function

# mimick clingo's statistics output from Python script
def print_stats(ctl):
    print()
    print("Models       : " + str(int(ctl.statistics["summary"]["models"]["enumerated"])))
    print("Calls        : " + str(int(ctl.statistics["summary"]["call"]) + 1))
    print("Time         : " + "{:.3f}".format(ctl.statistics["summary"]["times"]["total"]) + "s (Solving: " + "{:.2f}".format(ctl.statistics["summary"]["times"]["solve"]) + "s 1st Model: " + "{:.2f}".format(ctl.statistics["summary"]["times"]["sat"]) + "s Unsat: " + "{:.2f}".format(ctl.statistics["summary"]["times"]["unsat"]) + "s)")
    print("CPU Time     : " + "{:.3f}".format(ctl.statistics["summary"]["times"]["cpu"]) + "s")

    print()
    print("Choices      : " + str(int(ctl.statistics["solving"]["solvers"]["choices"])))
    print("Conflicts    : " + str(int(ctl.statistics["solving"]["solvers"]["conflicts"])) + "    (Analyzed: " + str(int(ctl.statistics["solving"]["solvers"]["conflicts_analyzed"])) + ")")

    print()
    print("Variables    : " + str(int(ctl.statistics["problem"]["generator"]["vars"])) + "    (Eliminated:    " + str(int(ctl.statistics["problem"]["generator"]["vars_eliminated"])) + " Frozen: " + str(int(ctl.statistics["problem"]["generator"]["vars_frozen"])) + ")")
    constraints_binary = ctl.statistics["problem"]["generator"]["constraints_binary"]
    constraints_ternary = ctl.statistics["problem"]["generator"]["constraints_ternary"]
    constraints_other = ctl.statistics["problem"]["generator"]["constraints"]
    constraints = int(constraints_binary + constraints_ternary + constraints_other)
    print("Constraints  : " + str(constraints) + "   (Binary:  " + "{:.1f}".format(100 * constraints_binary / constraints) + "% Ternary:  " + "{:.1f}".format(100 * constraints_ternary / constraints) + "% Other:   " + "{:.1f}".format(100 * constraints_other / constraints) + "%)")

# print model(s) together with a running number
def on_model(m):
    global answer

    print("Answer: " + str(answer))
    print(m)

step = 0    # maximum number of disk moves
answer = 1  # running number for the models

# create a new clingo instance for the current step
ctl = clingo.Control(arguments = ["-n", "1", "--warn", "none"])

# load the logic program files
ctl.load("instance.lp")
ctl.load("hanoi_tower.lp")

todo = [("base", [])]

while step == 0 or not result.satisfiable:
    # ground instance and encoding for the current step
    print("Iteration " + str(step) + ":")
    todo.append(("goal", [clingo.Number(step)]))
    ctl.ground(todo)

    if step > 0: ctl.release_external(clingo.Function("last", [clingo.Number(step-1)]))
    ctl.assign_external(clingo.Function("last", [clingo.Number(step)]), True)

    # compute all models and proceed to the next step if there is none
    result = ctl.solve(on_model = on_model)
    step = step+1
    todo = [("action", [clingo.Number(step)])]

# print statistics about the last solving step
print_stats(ctl)

#!/usr/bin/env python

# COMMANDS TO RUN:
# python control.py instance_04.lp events_04.lp elevator.lp

import sys
import clingo
from clingo import Number, Function

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

# print model(s) together with a running number and read off next state + events
def on_model(m):
    global step
    global time
    global answer
    global todo
    global state
    global event

    print("Answer: " + str(answer))
    answer = answer+1
    state = []
    event = []

    for atom in m.symbols(shown=True):
        args = atom.arguments
        if atom.name == "next_schedule":
            n = args.pop(1).number
            if n == step:
                print(atom.name + "(" + str(args[0]) + ")", end=" ")
                time += args[0].number
                todo = True
        elif atom.name == "next_at" or atom.name == "next_priority":
            n = args.pop(3).number
            if n == step:
                state.append(Function(atom.name[5:], args))
        elif atom.name == "next_deliver":
            n = args.pop(3).number
            if n == step:
                state.append(Function("todo_" + atom.name[5:], args))
        elif atom.name == "next_call":
            n = args.pop(3).number
            if n == step:
                if args[2].number == 0:
                    state.append(Function("todo_" + atom.name[5:], args))
                args.append(Number(n+1))
                event.append(Function(atom.name[5:], args))
        elif atom.name == "next_call_deliver":
            n = args.pop(4).number
            if n == step:
                args.append(Number(n+1))
                event.append(Function(atom.name[5:], args))
        else: print(atom, end=" ")
    print("\nOptimization: " + str(m.cost[0]))

step = -1
time = 0
todo = True
state = []
event = []

while todo:
    step = step+1
    todo = False
    answer = 1

### DO SOMETHING LIKE THIS BEFORE THE WHILE LOOP TO PERFORM MULTI-SHOT SOLVING
    ctl = clingo.Control(arguments = ["--opt-strategy", "usc", "--warn", "none"])
    for arg in sys.argv[1:]: ctl.load(arg)
    ctl.load("next.lp")

    ctl.ground([("instance", []), ("events", [])])
    if step == 0:
        for atom in ctl.symbolic_atoms.by_signature("init", 2):
            args = atom.symbol.arguments
            args.append(Number(0))
            state.append(Function("at", args))
        for atom in ctl.symbolic_atoms.by_signature("call", 2):
            args = atom.symbol.arguments
            args.append(Number(0))
            state.append(Function("todo_call", args))
            args.append(Number(0))
            event.append(Function("call", args))
        for atom in ctl.symbolic_atoms.by_signature("deliver", 2):
            args = atom.symbol.arguments
            args.append(Number(0))
            state.append(Function("todo_deliver", args))
        for atom in ctl.symbolic_atoms.by_signature("priority", 2):
            args = atom.symbol.arguments
            args.append(Number(0))
            state.append(Function("priority", args))
        for atom in ctl.symbolic_atoms.by_signature("call", 3):
            args = atom.symbol.arguments
            args.append(Number(0))
            event.append(Function("call", args))
        for atom in ctl.symbolic_atoms.by_signature("call_deliver", 4):
            args = atom.symbol.arguments
            args.append(Number(0))
            event.append(Function("call_deliver", args))

        print("INITIAL STATE:", end="  ")
        print([str(a) for a in state])
        print("INITIAL EVENTS:", end=" ")
        print([str(a) for a in event])
### THE WHOLE ABOVE PART SHOULD NOT BE IN THE WHILE LOOP FOR MULTI-SHOT SOLVING

    facts_name = "fact_" + str(step) # UTILIZE EXTERNALS FOR MULTI-SHOT SOLVING
    events_name = "event_" + str(step) # the event program can be used as it is

    if state: ctl.add(facts_name, [], ".".join([str(a) for a in state]) + ".")
    if event: ctl.add(events_name, [], ".".join([str(a) for a in event]) + ".")

    print("===========================")
    print("CALL " + str(step) + " AT TIME " + str(time))

    ctl.ground([("base", []), ("next", [Number(step)]), (events_name, []), (facts_name, [])])
    ctl.solve(on_model = on_model)

    print("NEXT STATE:", end="  ")
    print([str(a) for a in state])
    print("NEXT EVENTS:", end=" ")
    print([str(a) for a in event])

# statistics can be printed by uncommenting the next line
#    print_stats(ctl)

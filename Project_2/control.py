#!/usr/bin/env python

# COMMANDS TO RUN:
# python control.py instance_04.lp events_04.lp elevator.lp

import sys
import clingo
from clingo import Number, Function

step = -1
todo = True

def on_model(m):
    global step
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
                    todo_atom = Function("todo_" + atom.name[5:], args)
                    state.append(todo_atom)
                    print("TODO: " + str(todo_atom))
                else:
                    args.append(Number(n+1))
                    event.append(Function(atom.name[5:], args))
        elif atom.name == "next_call_deliver":
            n = args.pop(4).number
            if n == step:
                args.append(Number(n+1))
                event.append(Function(atom.name[5:], args))
        else: print(atom, end=" ")
    print("\nOptimization: " + str(m.cost[0]))
#    print([str(a) for a in state])
#    print([str(a) for a in event])

while todo:
    step = step+1
    todo = False
    answer = 1

    print("===========================")
    print("Call: " + str(step))

    ctl = clingo.Control(arguments = ["--opt-strategy", "usc", "--warn", "none"])
    for arg in sys.argv[1:]: ctl.load(arg)
    ctl.load("next.lp")

#    if step == 0: ctl.add("at(E,F,0) :- init(E,F). todo_call(F,D,0) :- call(F,D). todo_deliver(E,F,0) :- deliver(E,F). priority(E,D,0) :- priority(E,D).")

    ctl.ground([("instance", [])])

    facts_name = "fact_" + str(step)
    events_name = "events_" + str(step)
    facts = ""
    events = ""
    if step == 0:
        for atom in ctl.symbolic_atoms.by_signature("init", 2):
            args = atom.symbol.arguments
            facts += "at(" + str(args[0]) + "," + str(args[1]) + ",0)."
        for atom in ctl.symbolic_atoms.by_signature("call", 2):
            args = atom.symbol.arguments
            facts += "todo_call(" + str(args[0]) + "," + str(args[1]) + ",0)."
        for atom in ctl.symbolic_atoms.by_signature("deliver", 2):
            args = atom.symbol.arguments
            facts += "todo_deliver(" + str(args[0]) + "," + str(args[1]) + ",0)."
        for atom in ctl.symbolic_atoms.by_signature("priority", 2):
            args = atom.symbol.arguments
            facts += "priority(" + str(args[0]) + "," + str(args[1]) + ",0)."
    else:
        facts = ".".join([str(a) for a in state]) + "."
        events = ".".join([str(a) for a in event]) + "."
        ctl.add(events_name, [], events)
#        print(facts)
#        print(events)
    
#    print(facts)
    ctl.add(facts_name, [], facts)
    ctl.ground([("base", []), ("next", [Number(step)]), (facts_name, []), (events_name, [])])
    ctl.solve(on_model = on_model)
    if step == 3: sys.exit()


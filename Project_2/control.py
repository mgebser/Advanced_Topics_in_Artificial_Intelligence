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
            print(atom.name + "(" + str(args[0]) + ")", end=" ")
#            todo = True
        elif atom.name == "next_at" or atom.name == "next_deliver" or atom.name == "next_priority":
            n = args.pop(3)
            if n == step:
                state.append(Function(atom.name, args))
        elif atom.name == "next_call":
            n = args.pop(3)
            if args[2] == 0:
                if n == step:
                    state.append(Function(atom.name, args))
            else:
                print(atom, end=" ") # TODO
        else: print(atom, end=" ")
    print("\nOptimization: " + str(m.cost[0]))

while todo:
    step = step+1
    todo = False
    answer = 1

    ctl = clingo.Control(arguments = ["--opt-strategy", "usc"])
    for arg in sys.argv[1:]: ctl.load(arg)
    ctl.load("next.lp")

    if step == 0: ctl.add("at(E,F,0) :- init(E,F). todo_call(F,D,0) :- call(F,D). todo_deliver(E,F,0) :- deliver(E,F). priority(E,D,0) :- priority(E,D).")

    ctl.ground([("base", []), ("next", [Number(step)])])
    ctl.solve(on_model = on_model)


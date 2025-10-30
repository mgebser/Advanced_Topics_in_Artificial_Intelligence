#!/usr/bin/env python

# COMMANDS TO RUN:
# python extensible.py

import clingo

ctl = clingo.Control(arguments = ["-n", "0", "--output", "text"])

ctl.load("extensible.lp")

ctl.ground([("base", [])])
ctl.solve(on_model = lambda m: print("Answer: {}".format(m)))

print("=====================================")

ctl.ground([("extensible", [])])
ctl.assign_external(clingo.Function("e" , [clingo.Number(1)]), None)
ctl.assign_external(clingo.Function("e" , [clingo.Number(2)]), None)
ctl.solve(on_model = lambda m: print("Answer: {}".format(m)), assumptions = [(clingo.Function("g", [clingo.Number(1)]), True)])

#!/usr/bin/env python

# COMMANDS TO RUN:
# python control-external.py

import clingo

ctl = clingo.Control()

ctl.load("chemistry-external.lp")
ctl.ground([("base", []), ("acid", [clingo.Number(42)])])
ctl.solve(on_model = print)

ctl.assign_external(clingo.Function("d" , [clingo.Number(2), clingo.Number(42)]), True)
ctl.solve(on_model = print)

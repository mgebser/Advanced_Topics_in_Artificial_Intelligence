#!/usr/bin/env python

# COMMANDS TO RUN:
# python control-acid.py

import clingo

ctl = clingo.Control()

ctl.load("chemistry.lp")
ctl.ground([("acid", [clingo.Number(42)])])
ctl.solve(on_model = print)

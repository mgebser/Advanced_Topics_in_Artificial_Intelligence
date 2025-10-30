% COMMANDS TO RUN:
% clingo control-acid.lp chemistry.lp

#script(python)

from clingo import Number

def main(prg):
    prg.ground([("acid", [Number(42)])])
    prg.solve()

#end.

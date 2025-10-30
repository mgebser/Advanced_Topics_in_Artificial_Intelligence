% COMMANDS TO RUN:
% clingo control-base.lp chemistry.lp

#script(python)

def main(prg):
    prg.ground([("base",[])])
    prg.solve()

#end.

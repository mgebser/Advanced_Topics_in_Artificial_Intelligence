% COMMANDS TO RUN:
% clingo control-external.lp chemistry-external.lp
% clingo control-external.lp chemistry-external.lp --output-debug=text

#script(python)

from clingo import Function, Number

def main(prg):
    prg.ground([("base", []), ("acid", [Number(42)])])
    prg.solve()
    prg.assign_external(Function("d" , [Number(2), Number(42)]), True)
    prg.solve()

#end.

# Project 3

As exact planning horizon optimization is computationally costly (especially for high-rise buildings), AIlevator Inc. aims to switch to a more light-weight approximation of the elevators' workload. The idea is to estimate the distances elevators need to move (or can avoid, respectively), and to make use of Difference Logic (DL) and [clingo-dl](https://potassco.org/labs/clingoDL/) for a compact representation. This change requires some adjustments of the previous solution from [Project 2](./../Project_2), which we summarize in the following.

## Problem Encoding Adjustments

The fact format of problem instances (and events) remains unchanged, while the previous optimization criterion

    :~ at(E,F,T). [1,T]

is replaced by a new approach in [elevator.lp](./elevator.lp):

    final_floor(F,D) :- floor(F), dir(D), not floor(F+D).

    visit_floor(E,F) :- at(E,F,0).
    visit_floor(E,F) :- todo_deliver(E,F,0).
    visit_floor(E,F) :- assign(E,F,D).

    skip_floors(E,D,D*G-M) :- elevator(E), final_floor(G,D),
                              M = #max{D*F : visit_floor(E,F)}.
    skip_floors(E,M1)      :- skip_floors(E,D,M1), skip_floors(E,-D,M2), M2 <= M1.

    :~ M = #min{M1 : skip_floors(E,M1)}. [-M]

This is a plain ASP encoding of the approximation criterion to optimize. The `visit_floor(E,F)` atoms indicate the floors `F` an elevator `E` is scheduled to visit, `skip_floors(E,D,M')` atoms determine the number `M'` of unvisited floors in direction `D` (`-1` for down and `1` for up), and `skip_floors(E,M)` provides the maximum value `M` of the two directions. For example, when the atoms `visit_floor(e(1),2)` and `visit_floor(e(1),3)` hold for a building with five floors, we obtain `skip_floors(e(1),-1,1)`, `skip_floors(e(1),1,2)`, and `skip_floors(e(1),2)`. The latter atom expresses that the elevator `e(1)` doesn't need to visit `2` floors in some direction. Finally, the minimum of such values over all elevators is determined by a `#min` aggregate and taken as objective to maximize (or minimize its inverse, respectively). Iterated single-shot solving, using the approximation as optimization objective, can then be accomplished by running the [control.py](./control.py) Python script.

The above formulation of the approximation criterion in terms of a weak constraint (starting with the `:~` connective) relies on [clingo](https://potassco.org/clingo/)'s built-in optimization methods. However, in this project, we want to switch to DL reasoning/optimization and [clingo-dl](https://potassco.org/labs/clingoDL/)
instead. The revised encoding version in [elevator.revised.lp](./elevator.revised.lp) prepares this transition by reformulating the previous weak
constraint and augmenting it with a program part as follows:

    skip(M) :- M = #min{M1 : skip_floors(E,M1)}.

    :~ skip(M). [-M]

    #program skipped(n).

    :- skip(M), M < n.

That is, the value `M` to maximize is provided by a `skip(M)` atom, and the `skipped(n)` program part consists of a constraint requiring `M` to be at least the parameter `n`. This allows for delegating the maximization to a dedicated loop in the revised [control.revised.py](./control.revised.py) Python script:

    while state != []:
        ret = ctl.solve(on_model = on_model)
        # store statistics when --stats flag is included in command line call
        # if stats: [...]
        if ret.unsatisfiable: state = []
        else:
            ctl.ground([("skipped", [Number(skipped+1)])])
            thy.prepare(ctl)

The loop accesses the value `M`, stored in the variable `skipped`, from `skip(M)` of the previous schedule and takes its increment as parameter value `n` for the `skipped(n)` program part. In this way, the next schedule is required to yield a greater value `M` (in `skip(M)`) than achieved before. The iterative incrementation will eventually lead to an unsatisfiable `solve` call, in which case an optimal schedule has been found and the loop is left.

Observe that the [control.revised.py](./control.revised.py) script already includes all functionality required to switch from plain ASP to DL reasoning/optimization by [clingo-dl](https://potassco.org/labs/clingoDL/), yet the encoding (of the approximation criterion) still needs to be reformulated accordingly.

## DL Reasoning/Optimization in this Project

The **main goal** of this project is to modify the rules and weak constraint specifying the approximation criterion to optimize, specifically:

    skip_floors(E,D,D*G-M) :- elevator(E), final_floor(G,D),
                              M = #max{D*F : visit_floor(E,F)}.
    skip_floors(E,M1)      :- skip_floors(E,D,M1), skip_floors(E,-D,M2), M2 <= M1.
    
    skip(M) :- M = #min{M1 : skip_floors(E,M1)}.

    :~ skip(M). [-M]

    #program skipped(n).

    :- skip(M), M < n.

Rather than using `#max` or `#min` aggregates and ASP variables like `M` for numeric values, we want to take advantage of DL variables and `&diff` atoms for a compact representation of numeric values and constraints on them. Note that, when changing from a `skip(M)` atom to a DL variable called `skip` for the value to maximize, the [control.revised.py](./control.revised.py) script should work out of the box without requiring any modifications.

**Note:** Please reintroduce your rules for the conditions on elevator control from [Project 1](./../Project_1) in the encoding for this project. The inclusion of such rules should be entirely transparent to the (non-)use of DL variables for optimization.

While the [control.revised.py](./control.revised.py) script already includes some multi-shot solving functionality for optimization w.r.t. a given initial state, a new clingo control object is created whenever dynamic events take place. The **secondary goal** of this project is to switch to full multi-shot solving by reusing a single clingo control object for different initial states. This requires changes similar to [Project 2](./../Project_2) on the problem encoding and Python script.

In addition, the `skipped(n)` program part

    #program skipped(n).

    :- skip(M), M < n.

needs to be conditioned on external atoms, as with the `horizon(h)` program part in [differencee.lp](../Slides/Effective_Modeling_in_ASP_modulo_Theories/differencee.lp) and the corresponding [control.py](../Slides/Effective_Modeling_in_ASP_modulo_Theories/control.py) Python script for the Flexible Job-Shop Scheduling Problem. As the external atoms require specific maintenance to switch between different initial states without risking unintended unsatisfiability, please turn to the secondary project goal only after fully completing the main goal. In fact, partial solutions that skip the secondary goal will receive significant proportional points already.

A submission should consist of modified versions of the problem encoding in [elevator.revised.lp](./elevator.revised.lp) (or [elevator.lp](./elevator.lp)) and the script in [control.revised.py](./control.revised.py) (or [control.py](./control.py)), together with a runtime comparison (documented in a separate text or PDF file) between the supplied plain ASP version and your (multi-shot) DL solution on a suitably chosen subset of the available instances. Please submit your solution by Wednesday, January 21, 2026 via the [Project 3 Submission link](https://tc.tugraz.at/main/mod/assign/view.php?id=543204).

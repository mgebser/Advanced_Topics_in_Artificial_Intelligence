# Project 1

The start-up company AIlevator Inc. is quickly growing. Their innovation consists of harnessing AI methods to optimize the scheduling and control of elevators in multi-storey buildings. In contrast to traditional approaches, the elevators in a building need not be exhaustively reprogrammed, but it suffices to connect them to a standard computer performing the optimization. Since the solution offered by AIlevator Inc. is agnostic to the specific building layout, i.e., the number of elevators and floors to manage, it is faster and cheaper to deploy than any other technology.

## Problem Instance Format

The core idea of AIlevator Inc. is to represent the elevator(s) in a building as well as state information for scheduling by a problem instance in Answer Set Programming (ASP), using facts like in [instance_04.lp](./instance_04.lp):

    floor(1).
    floor(2).
    floor(3).
    floor(4).
    floor(5).
    elevator(e(1)).
    elevator(e(2)).
    init(e(1),1).
    init(e(2),2).
    call(3,-1).
    call(3,1).
    call(4,-1).
    call(5,-1).
    deliver(e(2),3).
    horizon(15).
    priority(e(2),1).

These facts express that the building possesses five floors, numbered from the bottom floor `1` to the top floor `5`, and two elevators: `e(1)` and `e(2)`. Initially, the elevator `e(1)` is located at floor `1`, and the elevator `e(2)` at floor `2`. Requests by persons calling some elevator are represented by atoms of the form `call(F,D)`, where `F` stands for a floor and `D` signals a direction: `-1` for down and `1` for up. Moreover, a `deliver(E,F)` atom signals that persons inside the elevator `E` want to go to floor `F`. The planning horizon is given by an atom of the form `horizon(T)`, where `T` limits the number of actions each elevator can perform for fulfilling the call and delivery requests. Last but not least, for each elevator `E` that needs to serve some delivery request(s), a `priority(E,D)` atom provides the information that the most recent past action by `E` (which is not explicitly given by the facts) has been dedicated towards serving a delivery request in the direction `D`. Note that such `priority(E,D)` atoms have only been introduced recently in order to improve the quality of schedules, which is the goal of this project.

## Current Problem Encoding

The general problem encoding in [elevator.lp](./elevator.lp) is currently used by AIlevator Inc. to compute optimized schedules with the ASP system [clingo](https://potassco.org/clingo/). It considers the maximum number of actions any elevator needs to perform until all call and delivery requests are fulfilled as objective to minimize. In addition to this optimization target, the encoding guarantees that scheduled actions are relevant to the request(s) an elevator serves. In a nutshell, an elevator can only move towards floors where it needs to fulfill some request(s), and it will only halt in order to serve these requests.

For example, an optimal schedule can be computed by running [clingo](https://potassco.org/clingo/) as follows:

    clingo instance_04.lp elevator.lp --opt-strategy=usc --configuration=handy
    clingo version 5.8.1 (cc20bdf)
    Reading from instance_04.lp ...
    Solving...
    Progression : [     2;inf] (Time: 0.013s)
    Progression : [     3;inf] (Time: 0.013s)
    Progression : [     4;inf] (Time: 0.014s)
    Progression : [     5;inf] (Time: 0.014s)
    Progression : [     6;inf] (Time: 0.014s)
    Answer: 1 (Time: 0.014s)
    at(e(1),1,0) at(e(2),2,0) at(e(2),3,1) move(e(2),1,1) at(e(1),2,1) move(e(1),1,1) at(e(2),3,2) serve(e(2),-1,2) at(e(1),3,2) move(e(1),1,2) serve(e(2),1,3) at(e(2),3,3) at(e(1),4,3) move(e(1),1,3) at(e(2),4,4) at(e(1),5,4) move(e(1),1,4) move(e(2),1,4) at(e(1),5,5) serve(e(1),-1,5) at(e(2),4,5) serve(e(2),-1,5)
    Optimization: 6
    OPTIMUM FOUND
    
    Models       : 1
      Optimum    : yes
    Optimization : 6
    Calls        : 1
    Time         : 0.014s (Solving: 0.00s 1st Model: 0.00s Unsat: 0.00s)
    CPU Time     : 0.014s

The elevators' actions are characterized by atoms of two forms, `move(E,D,T)` and `serve(E,D,T)`, where `E` denotes an elevator, `D` a direction (`-1` or `1`), and `T` a time point in-between `1` and the planning horizon. The direction `D` in `serve(E,D,T)` matters regarding call requests at the current floor `F` of `E`, as only a call request for the direction `D` can be served and a separate action would be required for the opposite direction. The floors `F` of elevators `E` resulting from the initial floors and actions are given by atoms of the form `at(E,F,T)` for time points from `0` up to the one matching the last action scheduled for `E`. In fact, the maximum time point `T` occurring in such atoms
is the target of minimization, and in the worst case it would match the planning horizon.

## Encoding Improvements in this Project

In the first proof-of-concept studies, AIlevator Inc. deployed their solution in comparably small buildings, where the schedule optimization worked seamlessly to let the elevators (often a single one) serve all requests in the virtually best possible way. Now that they started with the larger rollout, some unexpected phenomena were observed and reported by persons who were wondering.

The following urgent issues were identified and need to be fixed as soon as possible by suitably extending the current problem encoding in [elevator.lp](./elevator.lp):

1. The optimization objective of minimizing the maximum number of actions any elevator performs risks that another elevator needing fewer (relevant) actions moves unnecessarily back and forth between floors before eventually moving on to a floor where persons wait that their call request gets served. Such unnecessary successive moves in opposite directions are for example observed in the optimal schedule stored in [solution_15.lp](./solution_15.lp), which contains the atoms `move(e(3),1,9)` and `move(e(3),-1,10)`. This means that the elevator `e(3)` moves up to floor `25` and then back down to floor `24`, so that `e(3)` wastes time before serving a call request at floor `24`.

   The first part of the encoding improvement task in this project is to add rules and/or constraints to [elevator.lp](./elevator.lp) that reject unnecessary successive moves by any elevator in opposite directions.

2. The current encoding internally assigns each call request to exactly one elevator that is supposed to serve it. The rationale is that sending multiple elevators to serve a single request would introduce redundant movements and increase the maintenance demands in the long run. However, despite it may be globally advantageous not to serve a call request immediately, it turns out that persons get worried when they see an elevator passing by their floor without stopping. Reconsidering the optimal schedule in [solution_15.lp](./solution_15.lp), a delay of serving the call request to go up from floor `24` is identified by a `missed_call(e(3),24,1,9)` indicator atom, which is augmented to the schedule to point out unintended behavior that should be corrected in the future. In fact, the elevator `e(3)` is scheduled to move up (in direction `1`) from floor `24` at time `9` without having served the call request, thus letting persons wait who were actually expecting to enter the elevator.

   The second part of the encoding improvement task is to add rules and/or constraints to [elevator.lp](./elevator.lp) making sure that serving call requests isn't delayed, i.e., moving away from a floor in the direction of a call request should be admitted only if the request has been served earlier or at the same time (by another elevator).

3. A similar consideration regarding delays applies to delivery requests, where persons inside an elevator want to go to a certain floor. While it may be globally advantageous for the optimization not to stop at the floor of a delivery request immediately, the persons expect to be served and wonder when the elevator moves on. For example, such a situation is pointed out by a `missed_deliver(e(1),46,2)` indicator atom for the optimal schedule in [solution_13.lp](./solution_13.lp). Here we have that the elevator `e(1)` passes by floor `46` without serving a delivery request (either `serve(e(1),1,2)` or `serve(e(1),-1,2)` would be required instead of `move(e(1),1,2)`), which gets still served later at time `27`, yet such a delay is unacceptable for persons inside the elevator.

   The third part of the encoding improvement task is to add rules and/or constraints to [elevator.lp](./elevator.lp) making sure that serving delivery requests isn't delayed, i.e., the elevator in charge of a delivery request must serve (in either direction) as soon as it reaches the floor of the request.

4. The most intricate shortcoming of the current encoding is that moving and serving directions do not need to adhere to delivery requests an elevator has to serve. This leads to odd situations when the elevator moves in the opposite direction (e.g., to serve call requests before proceeding to deliver persons inside the elevator) or serves call requests in the opposite direction (often leading to simultaneous delivery requests going both up and down). In order to avoid such ambiguity in the future, facts of the form `priority(E,D)` have been introduced to indicate that the elevator `E` is about to serve delivery requests in the direction `D` (if any remain), and should neither move nor serve in the opposite direction `-D` (moving or serving in the direction `D` is fine) as long as the prioritized delivery requests are not all served.

   What makes this condition tricky is that delivery requests of an elevator `E` may go into both directions (`D` and `-D`) right from the beginning, e.g., if persons press the wrong button for calling an elevator and change their mind once they enter the elevator. In such cases, the opposite direction `-D` should become prioritized as soon as all delivery requests in the original direction `D` have been served. In other words, some direction (either `1` or `-1`) in which an elevator needs to move towards the floor of a delivery request should take priority, and the priority should switch to the opposite direction (if there are such delivery requests) as soon as all initially prioritized delivery requests are served.

   For example, moves going opposite to the prioritized directions `-1` or `1`, respectively, of the elevators `e(1)` and `e(3)` are signaled by the `turned_move(e(1),1,1)` and `turned_move(e(3),-1,2)` indicator atoms for the optimal schedule in [solution_13.lp](./solution_13.lp). Moreover, that the elevator `e(2)` serves a call request opposite to its prioritized direction `1` is indicated by `turned_serve(e(2),-1,40)`.

   The fourth and most intricate part of the encoding improvement task in this project is to add rules and/or constraints to [elevator.lp](./elevator.lp) that keep track of an elevator's prioritized direction and make sure that neither moving nor serving go into the opposite direction as long as the prioritized delivery requests are not all served.

Partial solutions that do not incorporate all four of the above conditions can be submitted and will receive proportional points for the project. A submission should consist of an extended version of the problem encoding in [elevator.lp](./elevator.lp) together with a record of the optimization values reported by [clingo](https://potassco.org/clingo/) (documented in a separate text or PDF file) for the instances in files [instance_01.lp](./instance_01.lp) to [instance_19.lp](./instance_19.lp). It's expected that optimization values, corresponding to the maximum number of actions any elevator performs, increase in comparison to the length of optimal schedules for the original [elevator.lp](./elevator.lp) encoding reported in files [solution_01.lp](./solution_01.lp) to [solution_19.lp](./solution_19.lp). We recommend the options `--opt-strategy=usc --configuration=handy` for running [clingo](https://potassco.org/clingo/), which helped to improve the optimization efficiency in our preliminary tests.

**We strongly discourage the use of generative AI for solving this project**. Typical observations on generated encoding( part)s are that they are syntactically incorrect and cannot be run, change the semantics in unintended ways, or behave neutrally in the sense that they can simply be dropped without changing the semantics and affecting the performance of [clingo](https://potassco.org/clingo/). Hence, submissions that are untested, i.e., encodings that cannot be run with [clingo](https://potassco.org/clingo/) due to syntactic errors or lack a plausible record of the experimentally obtained optimization values, will not receive any points.

Please submit your solution by Wednesday, November 5, 2025 via the [Project 1 Submission link](https://tc.tugraz.at/main/mod/assign/view.php?id=525756).
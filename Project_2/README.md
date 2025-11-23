# Project 2

With the improved elevator control logic in place, AIlevator Inc. deploy their ASP-based solution in an increasing number of buildings, where they also handle the first high-rise buildings with several elevators and a substantial number of (call and delivery) requests that need to be continuously served. For streamlined software embedding upon replanning, AIlevator Inc. recently switched from running the executable of [clingo](https://potassco.org/clingo/) to calling its [API](https://potassco.org/clingo/python-api/current/) from a Python script. The changed architecture requires some adjustments of the previous solution from [Project 1](./../Project_1), which we summarize in the following.

## Problem Encoding Adjustments

Let us recall the format of facts as in [instance_04.lp](./instance_04.lp):

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

The (static) information given by atoms of the forms `floor(F)` and `elevator(E)` doesn't change when elevators move, requests get served and new ones arise. Moreover, `horizon(T)` still provides a suitable planning horizon for fulfilling typical call and delivery requests. What changes over time are the floors of elevators, call and delivery requests as well as the delivery priorities, i.e., the `init(E,F)`, `call(F,D)`, `deliver(E,F)` and `priority(E,D)` atoms. For this reason, the Python script for replanning doesn't consider these facts but injects dynamically generated facts like the following:

    at(e(1),1,0).
    at(e(2),2,0).
    todo_call(3,-1,0).
    todo_call(3,1,0).
    todo_call(4,-1,0).
    todo_call(5,-1,0).
    todo_deliver(e(2),3,0).
    priority(e(2),1,0).

As such facts change in each `solve` call, some of the previous rules are no longer used by the problem encoding in [elevator.lp](./elevator.lp) and thus commented:

    % at(E,F,0) :- init(E,F).
    % todo_call(F,D,0) :- call(F,D).
    % todo_deliver(E,F,0) :- deliver(E,F).

In this way, dynamic information can be accommodated by the problem encoding without modifying the existing problem instances.

# Python Script for Single-shot Solving

The recent version of AIlevator Inc.'s optimized elevator control runs with the [control.py](./control.py) Python script. Its `print_stats(ctl)` method (lines 11-28) isn't necessary but may be called (by uncommenting line 144) for profiling. The `on_model(m)` method (lines 31-73) not only prints an optimized schedule, but also extracts atoms relevant for the next `solve` call. That is, the `state` list gathers `at(E,F,0)`, `todo_call(F,D,0)`, `todo_deliver(E,F,0)` and `priority(E,D,0)` atoms that will be used next as dynamically generated facts. Moreover, the `event` list maintains information about future call and delivery requests, generated from facts as in [events_04.lp](./events_04.lp) and the auxiliary program part in [next.lp](./next.lp). The `event` list provides a mock interface to produce dynamic facts, while they result from a priori unknown events in the live system. Hence, the atoms in the `event` list must not be exploited and shouldn't occur in the [elevator.lp](./elevator.lp) encoding.

In analogy to running the [clingo](https://potassco.org/clingo/) executable from scratch, the main loop of [control.py](./control.py) (lines 81-144) creates a new clingo control object that loads all relevant logic program files (lines 87-89) in each iteration of the main loop. The first iteration extracts initial `state` and `event` lists from the given facts (lines 91-123). Both lists are then turned into facts (lines 126-130), and solving along with output anticipating the next `solve` call (if any) follow in the rest of the main loop (lines 132-141). The [control.py](./control.py) Python script can be invoked as follows:

    python control.py instance_04.lp events_04.lp elevator.lp

## Multi-shot Solving in this Project

Reconsidering the current approach, AIlevator Inc. identifies the creation of a new clingo control object (lines 87-89) for each `solve` call in [control.py](./control.py) as unnecessary overhead. By switching from the creation of dynamic facts for atoms in the `state` list to a suitable handling of external atoms, as illustrated by the example programs for [Multi-shot_Solving](./Slides/Multi-shot_Solving), further improvements may be achieved. That is, rather than recreating a new clingo control object (lines 87-89) in each iteration of the main loop, a clingo control object should be created and used to extract initial `state` and `event` lists (lines 91-123) only once. Within the modified main loop, former dynamic facts in the `state` list should then be asserted by assigning external `at(E,F,0)`, `todo_call(F,D,0)`, `todo_deliver(E,F,0)` and `priority(E,D,0)` atoms. However, the handling of the `event` list and the corresponding auxiliary `next(n)` program in [next.lp](./next.lp) should be kept as is.

The goals of this project are:

1. Make the problem encoding in [elevator.lp](./elevator.lp) amenable for multi-shot solving by introducing the aforementioned external atoms. Except for switching from facts of the form `priority(E,D)` to external `priority(E,D,0)` atoms, this modification should be transparent regarding the four conditions on elevator control encoded  in [Project 1](./../Project_1). Please reintroduce your rules for these conditions in the modified [elevator.lp](./elevator.lp) encoding.

2. Modify the [control.py](./control.py) Python script such that a clingo control object is created only once and reused for all `solve` calls in the main loop of (lines 81-144). Please feel free to modify any parts of the script as needed, e.g., you may produce additional or remove unwanted output information.

3. Please give a brief indication of the solving performance of your modified [elevator.lp](./elevator.lp) encoding and [control.py](./control.py) script by comparing the resulting runtime to the supplied single-shot version. For example, you may activate the statistics output by uncommenting the `print_stats(ctl)` call in line 144 of [control.py](./control.py). However, please be prepared that iterated replanning significantly increases the computational demands in comparison to just one `solve` call per instance, as performed in [Project 1](./../Project_1). Hence it is completely fine to focus on a few, computationally manageable instances only (where the scripts' runtime doesn't exceed 10-20 minutes), while disregarding instances for which the iterated replanning takes too long.

A submission should consist of modified versions of the problem encoding in [elevator.lp](./elevator.lp) and the script in [control.py](./control.py), together with a runtime comparison (documented in a separate text or PDF file) between the supplied single-shot version and your multi-shot solving solution on a suitably chosen subset of the available instances. Please submit your solution by Wednesday, December 3, 2025 via the [Project 2 Submission link](https://tc.tugraz.at/main/mod/assign/view.php?id=535595).

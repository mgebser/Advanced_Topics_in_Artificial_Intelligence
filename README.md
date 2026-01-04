# Advanced Topics in Artificial Intelligence

This repository collects course materials for Advanced Topics in Artificial Intelligence. The folders include:

* [Videos](./Videos): A recording of how to install the Answer Set Programming (ASP) system [clingo](https://potassco.org/clingo/) for Windows.

* [Slides](./Slides): Course slides and accompanying logic program files in subfolders.

  The [slides](https://github.com/potassco-asp-course/course/releases/download/v1.21.0/msolving.pdf) presenting logic programs in the subfolder [Multi-shot_Solving](./Slides/Multi-shot_Solving) are part of the [Potassco teaching materials](https://teaching.potassco.org/). The procedural code in Python files or script declarations, respectively, makes use of [clingo's Python API](https://potassco.org/clingo/python-api/current/). More such programs are contained in the [examples shipped with clingo](https://github.com/potassco/clingo/tree/master/examples/clingo), e.g., the implementation of clingo's [incmode](https://github.com/potassco/clingo/tree/master/examples/clingo/iclingo), as well as the [advanced clingo examples](https://potassco.org/clingo/examples/).

  The [ASP modulo Difference Logic slides](./Slides/Effective_Modeling_in_ASP_modulo_Theories.pdf) are based on a tutorial held at the [School on Logic Programming in 2022](https://sites.google.com/view/iclpdc2022/school-on-logic-programming). The corresponding [logic programs](./Slides/Effective_Modeling_in_ASP_modulo_Theories) can be run with the ASP system [clingo-dl](https://potassco.org/labs/clingoDL/), which provides a propagator and reasoning/optimization methods for Difference Logic (DL). A Python script and encoding part that combine optimization at the level of DL variables and standard atoms are given by [control.py](./Slides/Effective_Modeling_in_ASP_modulo_Theories/control.py) and [differencee.lp](./Slides/Effective_Modeling_in_ASP_modulo_Theories/differencee.lp).

* [Exercise_1](./Exercise_1): Example ASP modeling tasks to be investigated in the course sessions on October 16 and on October 23, where we look at the Ricochet Robots board game.

* [Project_1](./Project_1): Description and framework (problem instances, their reference solutions, and a problem encoding to extend) for the first project to be solved in groups of up to two students by **November 5**.

* [Exercise_2](./Exercise_2): Example multi-shot ASP solving tasks to be investigated in the course sessions on November 6 and on November 13.

* [Project_2](./Project_2): Description and framework (problem instances, a problem encoding and a Python script for iterated replanning) for the second project to be solved in groups of up to two students by ~~December 3~~ **December 10**.

* [Project_3](./Project_3): Description and framework (problem instances plus basic and revised versions of a problem encoding and a Python script for iterated replanning) for the second project to be solved in groups of up to two students by **January 21**.

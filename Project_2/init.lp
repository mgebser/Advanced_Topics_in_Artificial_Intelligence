at(E,F,0) :- init(E,F).

todo_call(F,D,0) :- call(F,D).
todo_deliver(E,F,0) :- deliver(E,F).

priority(E,D,0) :- priority(E,D).

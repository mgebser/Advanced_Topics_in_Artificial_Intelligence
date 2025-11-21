#program next(n).

has_call(F,D,T,T+1,n) :- call(F,D,T,n),
                         not serve_call(F,D,T,n), not has_call(F,D,T,n).
has_call(F,D,T',T,n)  :- has_call(F,D,T',T-1,n), time(T),
                         not serve_call(F,D,T-1,n).
has_call(F,D,T,n)     :- has_call(F,D,T',T,n).

serve_call(E,F,D,T,n) :- at(E,F,T-1), serve(E,D,T), call(F,D,T,n).
serve_call(E,F,D,T,n) :- at(E,F,T-1), serve(E,D,T), has_call(F,D,T,n).
serve_call(F,D,T,n)   :- serve_call(E,F,D,T,n).

served_call(e(N),F,D,T,n) :- serve_call(e(N+1),F,D,T,n), 1 < N.
served_call(e(N),F,D,T,n) :- served_call(e(N+1),F,D,T,n), 1 < N.

takes_call(E,F,D,T,n) :- serve_call(E,F,D,T,n), not served_call(E,F,D,T,n).

call_deliver(F',D,T',F,n) :- has_call(F',D,T',T,n), call_deliver(F',D,T,F,n).

next_deliver(E,F,T,n) :- takes_call(E,F',D,T,n), call_deliver(F',D,T,F,n),
                         not todo(E,F,T).
next_deliver(E,F,T,n) :- takes_call(E,F',D,T,n), call_deliver(F',D,T',F,n),
                         has_call(F',D,T',T,n), not todo(E,F,T).

reschedule(T,n) :- next_deliver(E,F,T,n).
reschedule(T,n) :- has_call(F,D,T,T+1,n), 0 < T.

rescheduled(T,n) :- reschedule(T+1,n), 0 <= T.
rescheduled(T,n) :- rescheduled(T+1,n), 0 <= T.

unschedule(T+1,n) :- reschedule(T,n), rescheduled(T,n).
unschedule(T+1,n) :- unschedule(T,n), rescheduled(T,n).

next_schedule(T,n) :- reschedule(T,n), not unschedule(T,n).

next_at(E,F,T+1,n) :- at(E,F,T), rescheduled(T,n),
                      not at(E,F,T+1), not at(E,F-1,T+1), not at(E,F+1,T+1).
next_at(E,F,T+1,n) :- next_at(E,F,T,n), rescheduled(T,n).

next_deliver(E,F-D,D,T,n) :- next_deliver(E,F,T,n), dir(D), floor(F-D),
                             next_schedule(T,n).
next_deliver(E,F-D,D,T,n) :- next_deliver(E,F,D,T,n), floor(F-D).

next_priority(E,D,T,n) :- at(E,F,T-1), next_deliver(E,F,D,T,n).
next_priority(E,D,T,n) :- at(E,F,T-1), move2deliver(E,F,D,T), next_schedule(T,n).
next_priority(E,D,T,n) :- can_deliver(E,F,T), move(E,-D,T), next_schedule(T,n).

#show next_schedule/2.

#show next_at(E,F,0,n) : at(E,F,T), next_schedule(T,n).
#show next_at(E,F,0,n) : next_at(E,F,T,n), next_schedule(T,n).

#show next_call(F,D,0,n)    : has_call(F,D,T+1,n), next_schedule(T,n).
#show next_call(F,D,T'-T,n) : call(F,D,T',n), next_schedule(T,n), T < T'.

#show next_deliver(E,F,0,n) : todo_deliver(E,F,T), next_schedule(T,n).
#show next_deliver(E,F,0,n) : next_deliver(E,F,T,n), next_schedule(T,n).

#show next_priority(E,D,0,n) : next_priority(E,D,T,n), move(E,D,T).
#show next_priority(E,D,0,n) : next_priority(E,D,T,n), serve(E,D,T).
#show next_priority(E,D,0,n) : next_priority(E,D,T,n), not next_priority(E,-D,T,n).

#show next_call_deliver(F',D,0,F,n)    : call_deliver(F',D,T',F,n),
                                         next_schedule(T,n),
                                         has_call(F',D,T',T+1,n).
#show next_call_deliver(F',D,T'-T,F,n) : call_deliver(F',D,T',F,n),
                                         next_schedule(T,n), T < T'.

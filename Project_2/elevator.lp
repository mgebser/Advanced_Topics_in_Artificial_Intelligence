% EXAMPLE COMMANDS TO RUN:
% clingo instance_05.lp elevator.lp --opt-strategy=usc --configuration=handy --stats
% clingo instance_10.lp elevator.lp --opt-strategy=usc --configuration=handy --stats
% clingo instance_15.lp elevator.lp --opt-strategy=usc --configuration=handy --stats

% DOMAIN: Auxiliary predicates on available time points and directions

% Time points of elevator moves and serve actions are limited by the horizon
time(1..T) :- horizon(T).

% Directions of elevator moves and serve actions can be down (-1) or up (1)
dir(-1;1).

% Elevators start from their initial floors
% at(E,F,0) :- init(E,F).

% GENERATE + DEFINE + TEST: Choose elevator moves, serve actions, update states

% An elevator call request into the direction D (-1 or 1) is unserved at time 0
% todo_call(F,D,0) :- call(F,D).

% A delivery request of elevator E to floor F is unserved at time 0
% todo_deliver(E,F,0) :- deliver(E,F).

% All call and delivery requests must have been served at latest at the horizon
:- todo_call(F,D,T), horizon(T).
:- todo_deliver(E,F,T), horizon(T).

% Each call request is to be served by (exactly) one elevator
{assign(E,F,D) : elevator(E)} = 1 :- todo_call(F,D,0).

% Elevator E has to perform some actions to serve a call request assigned to it
todo(E,F,D,T) :- todo_call(F,D,T-1), time(T), assign(E,F,D).

% Elevator E has to perform some actions to serve one of its delivery requests
todo(E,F,T)   :- todo_deliver(E,F,T-1), time(T).

% Elevator E may move into direction D at time T to serve call request(s)
move2call(E,F-D,D,T) :- todo(E,F,D',T), dir(D), floor(F-D).
move2call(E,F-D,D,T) :- move2call(E,F,D,T), floor(F-D).

% Elevator E may move into direction D at time T to serve delivery request(s)
move2deliver(E,F-D,D,T) :- todo(E,F,T), dir(D), floor(F-D).
move2deliver(E,F-D,D,T) :- move2deliver(E,F,D,T), floor(F-D).

% Elevator E may move into direction D at time T to serve some call or delivery
move2serve(E,F,D,T) :- move2call(E,F,D,T).
move2serve(E,F,D,T) :- move2deliver(E,F,D,T).

% Elevator E is at a floor F where it can serve a delivery request at time T
can_deliver(E,F,T) :- at(E,F,T-1), todo(E,F,T).

% Elevator E can serve into direction D at time T if E is at a floor F with:
% - a respective, yet unserved call request, or
% - there is a yet unserved delivery request such that
%   - it matches a call request into the direction D,
%   - E may move on into direction D to serve further requests, or
%   - the direction D is down (-1) if there is no yet unserved request upwards
can_serve(E, D,T) :- at(E,F,T-1), todo(E,F,D,T).
can_serve(E, D,T) :- can_deliver(E,F,T), todo_call(F,D,T-1).
can_serve(E, D,T) :- can_deliver(E,F,T), move2serve(E,F,D,T).
can_serve(E,-1,T) :- can_deliver(E,F,T),
                     not todo_call(F,1,T-1), not move2serve(E,F,1,T).

% Elevator E can move into direction D at time T to serve some call or delivery
can_move(E,D,T) :- at(E,F,T-1), move2serve(E,F,D,T).

% Choose at most one move or serve action to perform per elevator E and time T
{move(E,D,T) : dir(D); serve(E,D,T) : dir(D)} 1 :- elevator(E), time(T).

% Move or serve actions can be performed only if they help to serve requests
:- move(E,D,T), not can_move(E,D,T).
:- serve(E,D,T), not  can_serve(E,D,T).

% A call request remains unserved if its assigned elevator E does not serve it
todo_call(F,D,T) :- todo(E,F,D,T), not at(E,F,T-1).
todo_call(F,D,T) :- todo(E,F,D,T), not serve(E,D,T).

% A delivery request of elevator E remains unserved if E does not serve it
todo_deliver(E,F,T) :- todo(E,F,T), not at(E,F,T-1).
todo_deliver(E,F,T) :- todo(E,F,T), not serve(E,-1,T), not serve(E,1,T).

% The floor of an elevator E is updated w.r.t. a performed move or serve action
at(E,F,T) :- at(E,F-D,T-1), move(E,D,T), floor(F).
at(E,F,T) :- at(E,F,T-1), serve(E,D,T).

% Each elevator is at at most one floor at any point of time (state constraint)
:- elevator(E), time(T), #count{F : at(E,F,T)} > 1.

% OPTIMIZE: All requests should be served within as few time points as possible

% Each time point at which some elevator still performs an action is penalized
:~ at(E,F,T). [1,T]

% DISPLAY: Output the floors and move or serve actions performed by elevators

#show at/3.
#show move/3.
#show serve/3.
#show todo_call(F,D,0) : todo_call(F,D,0).
#show todo_deliver(E,F,0) : todo_deliver(E,F,0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: Add rules/constraints making sure that ... %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1) No elevator ever performs successive moves going into opposite directions
sharp_turn(E,D,T) :- move(E,D,T), move(E,-D,T-1).
#show sharp_turn/3.
#show move(E,D,T) : sharp_turn(E,D,T).
#show move(E,-D,T-1) : sharp_turn(E,D,T).
:- sharp_turn(E,D,T).

% 2) Call requests are not left unserved, i.e., no elevator ever moves away
%    from a floor when a call request into its move direction remains unserved


% 3) Delivery requests are not left unserved, i.e., no elevator ever moves away
%    from a floor without serving any yet unserved delivery request


% 4) Once an elevator has started to move or serve into a direction, no move or
%    serve action goes into the opposite direction before deliveries are served


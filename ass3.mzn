include "globals.mzn";

% variables
int: nTables; % total number of tables
int: nGuests; % total number of tables
int: nSeats; % total number of seats
int: nGroups;
int: PrefWeight;
int: groupSize = 2;

%Troublemakers
array[1..2] of int: Trouble; % need to fix this

% Groups
array[1..nGroups] of set of int: Groups;

%Preference
array[1..nGuests] of set of int: Pref;

%Tables (for assignmetn)
set of int: Tables = 1..nTables;
set of int: GuestNum = 1..nGuests;
array[1..nGuests] of var GuestNum: GuestAt; % same as in description of assignment

% No table has more people at it than nSeats.
constraint 
forall(table in 1..nTables) (
    atmost(nSeats, GuestAt, table) 
);

%Every table must have at least ⌊nSeats/2⌋ people at it.
constraint 
forall(table in 1..nTables) (
    atleast(floor(nSeats/2), GuestAt, table)
 );


% Every person must be seated with their group.
constraint 
forall(g in 1..nGroups) (
      let { array[1..groupSize] of int: groupArray = set2array(Groups[g]) } in
        GuestAt[groupArray[1]] ==  GuestAt[groupArray[2]]
);

% Everyone in the set Trouble must be seated at different tables.
constraint 
forall(guest1, guest2 in 1..2) (    
        if guest1 == guest2 then true else GuestAt[Trouble[guest1]] != GuestAt[Trouble[guest2]] endif
);



      % set number of elements to 
      %card(tabletoo[t]) = GuestPerTable
 
      %% channel between tables and x (use int_set_channel instead)
      % /\
      % forall(j in 1..k) (
      %   x[j] = t <-> j in tables[t]
      % )




% make sure no guest is seated twice (every number unique)
%all_different(array [int] of var set of int: x)
%constraint forall(table in Seating)(alldifferent(Seating[table[i]]));

%constraint alldifferent(Seating[nGroups]);

%constraint forall(t in 1..nTables) (
 %     card(Seating[t])
%);


solve satisfy;




% output template:
%
% Table: Guests:
%   1 : {1,3,7}
%   2 : {2,5,6}
%   3 : {4,8,9}
%Utilitarian Happiness: 27
%Egalitarian Happiness: 3
%----------
output [if t == 1 /\ g == 1 then "Table: Guests:\n" else "" endif++
            if g == 1 then "   "++show(t)++" : {" else "" endif++
            if fix(GuestAt[g]) == t then show(g)++"," else "" endif ++
            if g == nGuests then "}\n" else "" endif % to to new line
            | t in 1..nTables, g in 1..nGuests 
            ]

include "globals.mzn";

% variables
int: Evaluation; %(0 = Utilitarian, 1 = Egalitarian)
int: nTables; % total number of tables
int: nGuests; % total number of tables
int: nSeats; % total number of seats
int: nGroups;
int: PrefWeight;
int: groupSize = 2;

%Troublemakers
set of int: Trouble; % need to fix this
% Groups
array[1..nGroups] of set of int: Groups;
%Preference
array[1..nGuests] of set of int: Pref;

%Tables (for assignmetn)
set of int: Tables = 1..nTables;
set of int: GuestNum = 1..nGuests;
array[1..nGuests] of var GuestNum: AtTable; % same as in description of assignment

% make sure there is somebody at every table
constraint
forall(guest in 1..nGuests) (
   AtTable[guest] <= nTables 
);

constraint 
forall(table in 1..nTables) (
    % No table has more people at it than nSeats.
    atmost(nSeats, AtTable, table) /\
    %Every table must have at least ⌊nSeats/2⌋ people at it.
    atleast(floor(nSeats/2), AtTable, table)
);


% Every person must be seated with their group.
constraint 
forall(g in 1..nGroups) (
      let { array[1..groupSize] of int: groupArray = set2array(Groups[g]) } in
        AtTable[groupArray[1]] ==  AtTable[groupArray[2]]
);

% Everyone in the set Trouble must be seated at different tables.
constraint 
forall(guest1, guest2 in 1..2) (    
        if guest1 == guest2 then true else AtTable[Trouble[guest1]] != AtTable[Trouble[guest2]] endif
);

% calculate utalitarian happiness
var int: utalitarian_hap = sum(guest in 1..nGuests, pref in 1..card(Pref[guest]))(
      % if table of guest equals table of a guest in the list of Pref[guest], add to util
      if AtTable[guest] == AtTable[Pref[guest][pref]] then PrefWeight else 0 endif
);

% calculate egalitarian happiness
var int: egalitarian_hap = min(guest in 1..nGuests)(
                                        sum(pref in 1..card(Pref[guest]))(   
      if AtTable[guest] == AtTable[Pref[guest][pref]] then PrefWeight else 0 endif
                                         )          
);

var int: happiness = if Evaluation == 0 then utalitarian_hap else egalitarian_hap endif;
solve maximize happiness;




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
            if fix(AtTable[g]) == t then show(g) ++ "," else "" endif ++
            if g == nGuests then "}\n" else "" endif % to to new line
            | t in 1..nTables, g in 1..nGuests ] ++
            ["Utilitarian Happiness: " ++ show(utalitarian_hap) ++ "\n" ++
             "Egalitarian Happiness: " ++ show(egalitarian_hap) ];
            

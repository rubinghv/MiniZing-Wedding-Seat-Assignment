include "globals.mzn";

% variables
int: Evaluation; %(0 = Utilitarian, 1 = Egalitarian)
int: nTables; % total number of tables
int: nGuests; % total number of tables
int: nSeats; % total number of seats
int: nGroups;
int: PrefWeight;

%Troublemakers
set of int: Trouble; 
% Groups
array[1..nGroups] of set of int: Groups;
%Preference
array[1..nGuests] of set of int: Pref;

%Decision variable
set of int: GuestNum = 1..nGuests;
array[1..nGuests] of var GuestNum: AtTable; % same as in description of assignment

% make sure that everybody is seated
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
% needs fixing
constraint 
forall(g in 1..nGroups) (
      %let { array[1..groupSize] of int: groupArray = set2array(Groups[g]) } in
      %AtTable[groupArray[1]] ==  AtTable[groupArray[2]]
      forall(p in 1..card(Groups[g])) (      
          AtTable[Groups[g][1]] ==  AtTable[Groups[g][p]]
      )
);

% Everyone in the set Trouble must be seated at different tables.
constraint 
forall(guest1, guest2 in 1..card(Trouble)) (    
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


% maximize either egalitarian or utalitarian happiness 
var int: happiness = if Evaluation == 0 then utalitarian_hap else egalitarian_hap endif;
solve maximize happiness;


%array[1..nTables] of int: some_array = (a in 1..nTables)(0);


% output template:
%
% Table: Guests:
%   1 : {1,3,7}
%   2 : {2,5,6}
%   3 : {4,8,9}
%Utilitarian Happiness: 27
%Egalitarian Happiness: 3
%----------
          
output ["Table: Guests:\n"] ++ 
            [if g == 1 then "   "++show(t)++" : {" else "" endif++
            if fix(AtTable[g]) == t then "," ++ show(g)  else "" endif ++
            if g == nGuests then "}\n" else "" endif % to to new line
            | t in 1..nTables, g in 1..nGuests ] ++
            ["Utilitarian Happiness: " ++ show(utalitarian_hap) ++ "\n" ++
             "Egalitarian Happiness: " ++ show(egalitarian_hap) ];

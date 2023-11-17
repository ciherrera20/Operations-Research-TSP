param N >= 0;  # N the number of destinations

set Meals;
set Locations := 0..N-1;
set Restaurants within Locations;
set Destinations within Locations;
set S := 0 .. N-1; # same as Locations
set SS := 0 .. 2**N-1;
set SS_E := 1 .. 2**N-2;
set POW {k in SS} := {i in S: (k div 2**i) mod 2 = 1};

param travel_time{Locations, Locations} >= 0;
param duration{Locations} >= 0;
param happiness{Locations} >= 0;
param anger_coef >= 0;
param total_time >= 0;
param meal_time{Meals} >= 0;

var visited{Locations} binary;
var visited_edge{Locations, Locations} binary;
var meal_ate{Locations, Meals} binary;
var arrival_time{Locations} >= 0;
var leaving_time{Locations} >= 0;
var order{Locations, Locations} binary; # does i come before j
var meal_ate_time{Meals} >= 0;
var meal_time_difference{Meals} >= 0;
# use big M instead of travel time

maximize Happiness:
    (sum{i in Locations} happiness[i]* visited[i]) - anger_coef* (sum{m in Meals} meal_time_difference[m]);

subject to Calc_Meal_Time_Difference{m in Meals}:
    -1*meal_ate_time[m] + meal_time[m] <= meal_time_difference[m] >= meal_ate_time[m] - meal_time[m];

subject to Calc_Arrival_Time{i in Locations, j in Locations, i <> j}:
    arrival_time[i] >= arrival_time[j] + duration[j] + travel_time[j, i] - total_time*order[i,j] - total_time*(1-visited_edge[i,j]);
    # arrival_time[i] >= arrival_time[j] + duration[j] + travel_time[j, i] - total_time*order[i,j] - total_time*(1-visited[i]) - total_time*(1-visited[j]);

subject to Only_One_Ordering{i in Locations, j in  Locations, i <> j}:
    order[i,j] + order[j, i] = 1;

subject to Calc_Leaving_Time{i in Locations}:
    leaving_time[i] = arrival_time[i] + duration[i];

subject to Calc_Meal_Ate_Time{m in Meals, r in Restaurants}:
    arrival_time[r] + (1-meal_ate[r, m])*total_time >= meal_ate_time[m] >= arrival_time[r] - (1-meal_ate[r, m])*total_time;

subject to LinkVisitedEdgeAndVisted{i in Locations}:
    visited[i] = (sum{j in Locations} visited_edge[i,j])/2;


# Enforce an undirected graph
subject to SymmetryConstraint{i in Locations, j in Locations}:
    visited_edge[i, j] = visited_edge[j, i];

# Ignore the edges connecting a vertex to itself
subject to SelfEdgeConstraint{i in Locations}:
    edge[i, i] = 0;

subject to SingleCycle{X in SS_E}:
    sum{i in POW[X], j in POW[X]} visited_edge[i, j] <= 2 * (card(POW[X]) - 1) + M*(card(POW[X]) - sum{i in POW[X]} visited[i]);


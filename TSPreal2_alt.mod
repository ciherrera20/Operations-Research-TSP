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
param M >= 0;
param starting_location >= 0;

var visited{Locations} binary;
var visited_edge{Locations, Locations} binary;
var meal_ate{Restaurants, Meals} binary;
var arrival_time{Locations} >= 0;
var leaving_time{Locations} >= 0;
var order{Locations, Locations} binary; # does i come before j
var meal_ate_time{Meals} >= 0;
var meal_time_difference{Meals} >= 0;
# use big M instead of travel time

# var c_zero{SS_E} binary;
# var c_one{SS_E} binary;
# var c_two{SS_E} binary;


minimize total_travel_time:
    (sum {i in Locations} leaving_time[i]);

subject to previous_obj_function:
    (sum{i in Destinations} happiness[i]* visited[i]) + (sum{r in Restaurants} happiness[r]* sum{m in Meals} meal_ate[r, m]) - anger_coef * (sum{m in Meals} meal_time_difference[m]) >= 50.3;

subject to starting_condition1:
arrival_time[starting_location] = 0;

subject to starting_condition2:
visited[starting_location] = 1;

subject to Calc_Arrival_Time {i in Locations, j in Locations: i <> j && j <> starting_location}:
arrival_time[j] >= arrival_time[i] + duration[i] + travel_time[i, j] -M*(1-visited_edge[i,j]);

subject to No_Arrival_Time {j in Locations}:
arrival_time[j] <= M*(visited[j]);

subject to Calc_Leaving_Time {i in Locations}:
leaving_time[i] = arrival_time[i] + duration[i];

subject to Calc_Meal_Ate_Time1{m in Meals, r in Restaurants}:
    arrival_time[r] + (1-meal_ate[r, m])*M >= meal_ate_time[m];

subject to Calc_Meal_Ate_Time2{m in Meals, r in Restaurants}:
    meal_ate_time[m] >= arrival_time[r] - (1-meal_ate[r, m])*M;

subject to Calc_Meal_Time_Difference1{m in Meals}:
    meal_time[m] - meal_ate_time[m] <= meal_time_difference[m];

subject to Calc_Meal_Time_Difference2{m in Meals}:
    meal_ate_time[m] - meal_time[m] <= meal_time_difference[m];

subject to NoSkipMeal{m in Meals}:
    sum{r in Restaurants} meal_ate[r, m] = 1;

subject to Total_Time {i in Locations}:
leaving_time[i] + travel_time[i,starting_location] <= total_time;

subject to LinkVisitedEdgeAndVisted{i in Locations}:
   visited[i] = sum{j in Locations} visited_edge[i,j]; # if there is an edge leaving from you u have been visited

# Ignore the edges connecting a vertex to itself
subject to SelfEdgeConstraint{i in Locations}:
    visited_edge[i, i] = 0;

subject to Degree{i in Locations}:
    sum{j in Locations} visited_edge[j,i] <=1;

# subject to SingleCycle{X in SS_E: (sum{k in Locations} visited[k])}:
#     sum{i in POW[X], j in POW[X]} visited_edge[i, j] <=  (card(POW[X]) - 1) + M*(card(POW[X]) - sum{i in POW[X]} visited[i]);

# subject to SubTour{X in SS_E}:
# sum{i in POW[X], j in POW[X]} visited_edge[i,j] <= (card(POW[X]) - 1) + M*(1-c_zero[X]);

# subject to CalcCzero1{X in SS_E}:
# c_zero[X] <= c_one[X];

# subject to CalcCzero2{X in SS_E}:
# c_zero[X] <= c_two[X];

# subject to CalcCzero3{X in SS_E}:
# c_zero[X] >= c_one[X] + c_two[X] -1;

# subject to AllVisitedContraint1{X in SS_E}:
# c_one[X] <= (1/card(POW[X]))*sum{i in POW[X]} visited[i];

# subject to AllVisitedContraint2{X in SS_E}:
# c_one[X] >= 1- (card(POW[X]) - sum{i in POW[X]} visited[i]);

# subject to LessThanTotalVisitedConstraint1{X in SS_E}:
# c_two[X] <= sum{i in Locations} visited[i] - (sum{i in POW[X]} visited[i]);

# subject to LessThanTotalVisitedConstraint2{X in SS_E}:
# c_two[X] <= (1/card(Locations)) * (sum{i in Locations} visited[i] - sum{i in POW[X]} visited[i]);

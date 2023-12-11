param N >= 0;  # N the number of destinations
param starting_location >= 0;
param ending_location >= 0;

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

var visited{Locations} binary;
var visited_edge{Locations, Locations} binary;
var meal_ate{Restaurants, Meals} binary;
var arrival_time{Locations} >= 0;
var leaving_time{Locations} >= 0;
var order{Locations, Locations} binary; # does i come before j
var meal_ate_time{Meals} >= 0;
var meal_time_difference{Meals} >= 0;

maximize Happiness:
    (sum{i in Locations} happiness[i]* visited[i]) - anger_coef * (sum{m in Meals} meal_time_difference[m]);

subject to Calc_Meal_Time_Difference1{m in Meals}:
    meal_time[m] - meal_ate_time[m] <= meal_time_difference[m];

subject to Calc_Meal_Time_Difference2{m in Meals}:
    meal_ate_time[m] - meal_time[m] <= meal_time_difference[m];

subject to Calc_Arrival_Time{i in Locations, j in Locations: i <> j and i<>0}:
    arrival_time[i] >= arrival_time[j] + duration[j] + travel_time[j, i] - total_time*(1-visited_edge[j,i]);
    # arrival_time[i] >= arrival_time[j] + duration[j] + travel_time[j, i] - total_time*order[i,j] - total_time*(1-visited[i]) - total_time*(1-visited[j]);
    
subject to InOut{i in Locations}:
	sum{x in Locations} visited_edge[x,i] >= sum{y in Locations} visited_edge[i,y];

subject to OneOut{i in Locations}:
	sum {j in Locations} visited_edge[i,j] <= 1;

subject to Calc_Leaving_Time{i in Locations}:
    leaving_time[i] = arrival_time[i] + duration[i];

subject to MealEatThere{m in Meals,r in Restaurants}:
	meal_ate[r,m] <= visited[r];

subject to Calc_Meal_Ate_Time1{m in Meals, r in Restaurants}:
    arrival_time[r] + (1-meal_ate[r, m])*M >= meal_ate_time[m];

subject to Calc_Meal_Ate_Time2{m in Meals, r in Restaurants}:
    meal_ate_time[m] >= arrival_time[r] - (1-meal_ate[r, m])*M;

subject to NoSkipMeal{m in Meals}:
    sum{r in Restaurants} meal_ate[r, m] = 1;

subject to LinkVisitedEdgeAndVisted{i in Locations}:
    visited[i] = (sum{j in Locations} visited_edge[j,i]);

subject to WithinLimit{i in Locations}:
	arrival_time[i] <= total_time;

subject to init:
	arrival_time[starting_location] = 0;
subject to init2:
	sum{j in Locations} visited_edge[starting_location,j] = 1;
subject to init3 {j in Locations}:
	arrival_time[ending_location] >= arrival_time[j];
subject to init4:
	sum{j in Locations} visited_edge[j,ending_location] = 1;
	
# Ignore the edges connecting a vertex to itself
subject to SelfEdgeConstraint{i in Locations}:
    visited_edge[i, i] = 0;


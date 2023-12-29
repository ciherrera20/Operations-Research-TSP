param N >= 0;  # N the number of destinations

set Meals;
set Locations := 0..N-1;
set Restaurants within Locations;
set Destinations within Locations;

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
var meal_ate_time{Meals} >= 0;
var meal_time_difference{Meals} >= 0;

maximize Happiness:
    sum{i in Locations} happiness[i]*visited[i] - anger_coef * (sum{m in Meals} meal_time_difference[m]);

# Ignore the edges connecting a vertex to itself
subject to SelfEdgeConstraint{i in Locations}:
    visited_edge[i, i] = 0;

# Calculate arrival time
subject to ArrivalTime {i in Locations, j in Locations: i <> j && j <> starting_location}:
    arrival_time[j] >= arrival_time[i] + duration[i] + travel_time[i, j] -M*(1-visited_edge[i,j]);

subject to NoArrivalTime {j in Locations}:
    arrival_time[j] <= M * visited[j];

# Calculate leaving time
subject to LeavingTime{i in Locations}:
    leaving_time[i] = arrival_time[i] + duration[i];

# We have to leave the last location with enough time to return to the start
subject to TotalTime{i in Locations}:
	leaving_time[i] + travel_time[i, starting_location] <= total_time;

# Cycle constraints
subject to IncomingEdges{i in Locations}:
    sum{j in Locations} visited_edge[j, i] = visited[i];

subject to OutgoingEdges{i in Locations}:
    sum{j in Locations} visited_edge[i, j] = visited[i];

# Starting constraints
subject to StartArrival:
    arrival_time[starting_location] = 0;

subject to StartVisited:
    visited[starting_location] = 1;

# Every meal is eaten exactly once
subject to NoSkipMeal{m in Meals}:
    sum{r in Restaurants} meal_ate[r, m] = 1;

# Restaurants are visited only for meals
subject to NoNonMeals{r in Restaurants}:
    sum{m in Meals} meal_ate[r, m] = visited[r];

# Calculate the time at which we eat meals
subject to Calc_Meal_Ate_Time1{m in Meals, r in Restaurants}:
    meal_ate_time[m] <= arrival_time[r] + M * (1 - meal_ate[r, m]);

subject to Calc_Meal_Ate_Time2{m in Meals, r in Restaurants}:
    meal_ate_time[m] >= arrival_time[r] - M * (1 - meal_ate[r, m]);

# Calculate meal time difference
subject to MealTimeDifference1{m in Meals}:
    meal_time[m] - meal_ate_time[m] <= meal_time_difference[m];

subject to MealTimeDifference2{m in Meals}:
    meal_ate_time[m] - meal_time[m] <= meal_time_difference[m];

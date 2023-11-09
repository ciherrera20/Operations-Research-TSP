param N >= 0;
param travel_time{0..N-1, 0..N-1} >= 0;
set S := 0 .. N-1;
set SS := 0 .. 2**N-1;
set SS_E := 1 .. 2**N-2;
set POW {k in SS} := {i in S: (k div 2**i) mod 2 = 1};
var edge{0..N-1, 0..N-1} >= 0;  # The edge i j means from vertex i to vertex j. It is outgoing from i and incoming to j.

# Sum the costs of each edge used
minimize TotalTime:
    sum{i in 0..N-1} (sum{j in 0..N-1} (edge[i, j] * travel_time[i, j])) / 2;

# Sum the outgoing edges at each vertex. This ensures that every vertex is part of a loop.
subject to LoopConstraint{i in 0..N-1}:
    sum{j in 0..N-1} edge[i, j] = 2;

# Enforce an undirected graph
subject to SymmetryConstraint{i in 0..N-1, j in 0..N-1}:
    edge[i, j] = edge[j, i];

# Ignore the edges connecting a vertex to itself
subject to SelfEdgeConstraint{i in 0..N-1}:
    edge[i, i] = 0;

# This constraint ensures that every edge will be given a value of 0 or 1, since only two 1s can sum to 2 in the loop constraint.
subject to MaxConstraint{i in 0..N-1, j in 0..N-1}:
    edge[i, j] <= 1;

subject to SingleCycle{X in SS_E}:
    sum{i in POW[X], j in POW[X]} edge[i, j] <= 2 * (card(POW[X]) - 1);

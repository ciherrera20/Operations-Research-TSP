param N >= 0;
param travel_time{1..N, 1..N} >= 0;
param desired{1..N, 1..N} >= 0;
var edge{1..N, 1..N} >= 0;  # The edge i j means from vertex i to vertex j. It is outgoing from i and incoming to j.
var diffs{1..N, 1..N} >= 0;

# Sum the costs of each edge used
minimize Diffs:
    sum{i in 1..N, j in 1..N} diffs[i, j];

subject to AbsConstraintPos{i in 1..N, j in 1..N}:
    diffs[i, j] >= desired[i, j] - edge[i, j];

subject to AbsConstraintNeg{i in 1..N, j in 1..N}:
    diffs[i, j] >= edge[i, j] - desired[i, j];

# Sum the outgoing edges at each vertex. This ensures that every vertex is part of a loop.
subject to LoopConstraint{i in 1..N}:
    sum{j in 1..N} edge[i, j] = 2;

# Enforce an undirected graph
subject to SymmetryConstraint{i in 1..N, j in 1..N}:
    edge[i, j] = edge[j, i];

# Ignore the edges connecting a vertex to itself
subject to SelfEdgeConstraint{i in 1..N}:
    edge[i, i] = 0;

# This constraint ensures that every edge will be given a value of 0 or 1, since only two 1s can sum to 2 in the loop constraint.
subject to MaxConstraint{i in 1..N, j in 1..N}:
    edge[i, j] <= 1;

subject to Optimality:
    sum{i in 1..N} (sum{j in 1..N} (edge[i, j] * travel_time[i, j])) / 2 = 5;

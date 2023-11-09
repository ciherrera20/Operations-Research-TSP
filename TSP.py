import numpy as np
from collections import deque
# import fileinput
# import re;

# if __name__ == '__main__':
#     size_pattern = re.compile(r'^N = (\d+)$')
#     edge_pattern = re.compile(r'^(\d+) (\d+)   ([01])$')
#     reading_edges = False
#     for line in fileinput.input():
#         if not reading_edges:

def get_components(adjacency_matrix, verbose=False):
    n = len(adjacency_matrix)

    unvisited = set(list(range(n)))
    stack = deque()
    components = []

    if verbose:
        print('Unvisited: ', list(unvisited))
        print('Stack:     ', list(stack))
        print('Components:', list(components))
        print('-----------------------------')

    while len(unvisited) > 0 or len(stack) > 0:
        # If nothing is on the stack, add a random vertex from the ones we haven't visited yet
        if len(stack) == 0:
            stack.append(unvisited.pop())
            components.append([])

        # Take the first vertex off the stack and mark it as visited
        v = stack.pop()
        components[-1].append(v)  # Add it to the current component

        # Add all its unvisited neighbors to the stack
        for w, adj in enumerate(adjacency_matrix[v]):
            if adj == 1 and w in unvisited:
                unvisited.remove(w)
                stack.append(w)
        
        if verbose:
            print('Unvisited: ', list(unvisited))
            print('Stack:     ', list(stack))
            print('Components:', list(components))
            print('-----------------------------')

    return components

if __name__ == '__main__':
    # # 10 by 10 with multiple loops
    # adjacency_matrix = np.array([
    #     [0, 0, 0, 0, 0, 0, 0, 1, 1, 0],
    #     [0, 0, 0, 0, 0, 1, 1, 0, 0, 0],
    #     [0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
    #     [0, 0, 1, 0, 1, 0, 0, 0, 0, 0],
    #     [0, 0, 1, 1, 0, 0, 0, 0, 0, 0],
    #     [0, 1, 0, 0, 0, 0, 1, 0, 0, 0],
    #     [0, 1, 0, 0, 0, 1, 0, 0, 0, 0],
    #     [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    #     [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    #     [0, 0, 0, 0, 0, 0, 0, 1, 1, 0]
    # ])

    # adjacency_matrix = np.array([
    #     [0, 0, 0, 1, 0, 1, 0, 0],
    #     [0, 0, 1, 0, 1, 0, 0, 0],
    #     [0, 1, 0, 1, 0, 0, 0, 0],
    #     [1, 0, 1, 0, 0, 0, 0, 0],
    #     [0, 1, 0, 0, 0, 0, 0, 1],
    #     [1, 0, 0, 0, 0, 0, 1, 0],
    #     [0, 0, 0, 0, 0, 1, 0, 1],
    #     [0, 0, 0, 0, 1, 0, 1, 0]
    # ])

    # Paris cities
    adjacency_matrix = np.array([
        [0, 1, 1, 0, 0],
        [1, 0, 0, 1, 0],
        [1, 0, 0, 0, 1],
        [0, 1, 0, 0, 1],
        [0, 0, 1, 1, 0]
    ])

    loops = get_components(adjacency_matrix)
    for loop in loops:
        for i in range(len(loop)):
            loop[i] += 1

    print('Loop(s):', *loops)

# Multi-Objective-Optimization-using-SIMPLEX
A new way to solve linear Bi-objective optimization problems using simplex.
Here we solve a Bi-objective optimizatino problem( multi-objective problem can also be solved by some simple modifications). Bi-objective optimization problem are defined as follows 
\begin{equation}
Z_1 = f_{1} (x_i) \forall i \in {1,...,n}
Z_2 = f_{2} (x_i) \forall i \in {1,...,n}

subject to:
Ax<b

\end{equation}

where $Z_1 and Z_2 $ are moving on oposite directions. i.e. the growth of one leads to the decrease of the other. Usually in this kind of problems, there is no unique solution. Instead, there are a group of non-dominated points where non of them can is better in both objectives. To find these points we will use simplex to find the optimum point of one of the objectives. then, we input that point as and initial point to the other objective function. All the points visited on the way would be non-dominated.

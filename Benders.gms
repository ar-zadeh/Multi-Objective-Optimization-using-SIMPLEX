sets
         jx             /1*70/
         jy             /1*50/
         i             /1*100/ ;
Parameter
         c(jx) Variable Costs;
loop(jx,
         C(jx)=uniform(350,400););
Parameter
         f(jy)  Fixed Cost;
loop(jy,
         f(jy)=uniform(700,800););
Parameter
         b(i)   Right Hand Sides;
loop(i,
         B(i)=uniform(1000,1550););
Parameter
         a(i,jx);
loop((i,jx),
         a(i,jx)=uniform(500,750););
Parameter
         d(i,jy);
loop((i,jy),
         d(i,jy)=uniform(900,1200););
variable
         z       Objective Function;
positive variable
         x(jx)   The amount we want to transport;
binary variable
         y(jy)   whether or not we wanna use route jy;
equations
         obj
         co1(i)
         ;
obj .. z =e= sum(jx,C(jx)*x(jx))+sum(jy,f(jy)*y(jy));
co1(i) .. sum(jx, a(i,jx)*x(jx))+sum(jy, d(i,jy)*y(jy)) =g=b(i) ;

model op  /obj,co1/;
option optcr=0,optca=0,MIP=Cplex;
*solve op using MIP min z;

*display z.l,x.l,y.l;
display "--------------------- BENDERS ALGORITHM ----------------------------";

scalar UB 'upperbound' /INF/;
scalar LB 'lowerbound' /-INF/;
y.l(jy) = 1;
*---------------------------------------------------------------------
* Benders Subproblem
*---------------------------------------------------------------------
variable zsub 'objective variable';
positive variables
u(i) ’duals’;
equations
   subobj          'objective'
   subconstr(jx)  'dual constraint'
;
* to detect unbounded subproblem
scalar unbounded /1.0e6/;
zsub.up = unbounded;
subobj..  zsub =e= sum(i,(b(i)-sum(jy,d(i,jy)*y.l(jy)))*u(i));
subconstr(jx).. sum(i,a(i,jx)*u(i))=l=c(jx);
model subproblem /subobj, subconstr/;
* reduce output to listing file:
subproblem.solprint=2;

subproblem.solvelink=0;

variable
dummy 'dummy objective variable';
equations
   modifiedsubobj          'objective'
   modifiedsubconstr(jx)  'dual constraint'
   edummy;
;
modifiedsubobj..
    sum(i,(b(i)-sum(jy,d(i,jy)*y.l(jy)))*u(i))=e= 1;

modifiedsubconstr(jx)..
    sum(i,a(i,jx)*u(i))=l= 0;
edummy.. dummy =e= 0;

model modifiedsubproblem /modifiedsubobj, modifiedsubconstr, edummy/;
* reduce output to listing file:
modifiedsubproblem.solprint=2;
* speed up by keeping GAMS in memory:
modifiedsubproblem.solvelink=0;

*---------------------------------------------------------------------
* Benders Relaxed Master Problem
*---------------------------------------------------------------------

set iter /iter1*iter50/;

set cutset(iter) 'dynamic set';
cutset(iter)=no;
set unbcutset(iter) 'dynamic set';
unbcutset(iter)=no;

variable z0 'relaxed master objective variable';
equations
   cut(iter)           'Benders cut for optimal subproblem'
   unboundedcut(iter)  'Benders cut for unbounded subproblem'
;

parameters
   cutconst(iter)     'constant term in cuts'
   cutcoeff(iter,i,jy)
;

cut(cutset).. z0 =g= sum(jy, f(jy)*y(jy))
                      + sum(i, b(i)*u.l(i))
                      + sum((i,jy), -d(i,jy)*u.l(i)*y(jy))
;
unboundedcut(unbcutset)..
                sum(i,(b(i)-sum(jy,d(i,jy)*y(jy))*u.l(i))) =l= 0
;
model master /cut,unboundedcut/;
* reduce output to listing file:
master.solprint=2;
* speed up by keeping GAMS in memory:
master.solvelink=0;
* solve to optimality
master.optcr=0;



scalar converged /0/;
scalar iteration;
scalar bound;
parameter ybest(jy);
parameter log(iter,*) 'logging info'
;
loop(iter$(not converged),

*
* solve Benders subproblem
*
   solve subproblem maximizing zsub using lp;

*
* check results.
*

   abort$(subproblem.modelstat>=2) "Subproblem not solved to optimality";

*
* was subproblem unbounded?
*

   if (zsub.l+1 < unbounded,

*
* no, so update upperbound
*
bound = sum((jy), f(jy)*y.l(jy)) + zsub.l;
      if (bound < UB,
          UB = bound;
          ybest(jy) = y.l(jy);
          display ybest;
      );
*
* and add Benders' cut to Relaxed Master
*
      cutset(iter) = yes;

   else

*
* solve modified subproblem
*

     solve modifiedsubproblem maximizing dummy using lp;

*
* check results.
*

     abort$(modifiedsubproblem.modelstat>=2)
            "Modified subproblem not solved to optimality";


*
* and add Benders' cut to Relaxed Master
*
      unbcutset(iter) = yes;
   );


*
* solve Relaxed Master Problem
*

   option optcr=0;
   solve master minimizing z0 using mip;

*
* check results.
*

   abort$(master.modelstat=4) "Relaxed Master is infeasible";
   abort$(master.modelstat>=2) "Masterproblem not solved to optimality";

*
* update lowerbound
*

   LB = z0.l ;

   log(iter,'LB') = LB;
   log(iter,'UB') = UB;

   iteration = ord(iter);
   display iteration,LB,UB;

   converged$( (UB-LB) < 0.1 ) = 1;
   display$converged "Converged";

);

display log;

abort$(not converged) "No convergence";

*
* recover solution
*
y.fx(jy) = ybest(jy);
op.solvelink=2;
op.solprint=0;
solve op minimizing z using rmip;
abort$(op.modelstat<>1) "final lp not solved to optimality";

display "Benders solution",y.l,x.l,z.l;

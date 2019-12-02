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
         a(i,jx) ;
loop((i,jx),
         a(i,jx)=uniform(500,750););
Parameter
         d(i,jy) ;
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

model op Still no idea! /all/;
option optcr=0,optca=0,MIP=Cplex;
solve op using MIP min z;

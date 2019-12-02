clear;
clc;
%   max Z1=C1*X%
%   max Z2=C2*X%
%   subject to: Ax=B%
    
C1=[5 -2 0 0 0 0];  %Coefficients of the objective function 1%
C2=[-1 4 0 0 0 0];  %Coefficients of the objective function 2%
A= [-1 1 1 0 0 0;
     1 1 0 1 0 0;
     1 0 0 0 1 0;
     0 1 0 0 0 1];  %Coefficients of variables%
B=[3;8;6;4];    %Right handside%
numofvariables=size(C1,2)-size(A,1);    %every limitation we add to our problem, needs a basic slack variables so the number of variables is the number of coefficinets in Objective functions substructed by the number of limitations%
Optimal1=0;   %initial values of obejtive func%
Optimal2=0;
flag=0;
counter=0;
while (max(C1)>0) %check if there is a variable that can enter the objective function%
  [x,y]=max(C1);  %finding the biggest one%
  temp=A(:,y)./B; 
  [i,j]=max(temp); %finding the variable that should leave the objective func%
  B(j)=B(j)/A(j,y); 
  Optimal1=Optimal1+B(j)*C1(y); %new value of obj func1%
  Optimal2=Optimal2+B(j)*C2(y); %new value of obj func2%
  A(j,:)=A(j,:)/A(j,y); %new value of constraint that has a variable that should exit%
  C1=C1-A(j,:)*C1(y);   
  C2=C2-A(j,:)*C2(y);  
  for k=1:size(A,1)
    if k==j
      continue
      endif
    B(k)=B(k)-B(j)*A(k,y); %new value of other right handsides%
    A(k,:)=A(k,:)-A(j,:)*A(k,y); %new value of every other constraint%
  endfor
endwhile

temperary=0;
X=zeros(1,numofvariables);
S=zeros(1,size(C1,2)-numofvariables);
%determining the value of variables and slacks%
for j=1:size(A,2)
  shomarande=0;
  for i=1:size(A,1)
    if A(i,j)==1
      shomarande=shomarande+1;
      temperary=i;
    endif
  endfor
  if shomarande==1
    if j<=numofvariables
      X(1,j)=B(temperary);
      endif
    if j>numofvariables
      S(1,j-numofvariables)=B(temperary);
    endif
  endif
endfor
X
S
A
B
C1
C2
Optimal1
Optimal2
pause;
X=zeros(1,numofvariables);
S=zeros(1,size(C1,2)-numofvariables);

% end of 1st simplex
while (max(C2)>0)
  [x,y]=max(C2);
  temp=A(:,y)./B;
  [i,j]=max(temp);
  B(j)=B(j)/A(j,y);
  Optimal1=Optimal1+B(j)*C1(y);
  Optimal2=Optimal2+B(j)*C2(y);
  A(j,:)=A(j,:)/A(j,y);
  C1=C1-A(j,:)*C1(y);
  C2=C2-A(j,:)*C2(y);  
  for k=1:size(A,1)
    if k==j
      continue
      endif
    B(k)=B(k)-B(j)*A(k,y);
    A(k,:)=A(k,:)-A(j,:)*A(k,y);
  endfor
for j=1:size(A,2)
  shomarande=0;
  for i=1:size(A,1)
    if A(i,j)==1
      shomarande=shomarande+1;
      temperary=i;
    elseif A(i,j)!=0
      shomarande=10;
    endif
  endfor
  if shomarande==1
    if j<=numofvariables
      X(1,j)=B(temperary);
      endif
    if j>numofvariables
      S(1,j-numofvariables)=B(temperary);
    endif
  endif
endfor
X
S
A
B
C1
C2
Optimal1
Optimal2
pause;
X=zeros(1,numofvariables);
S=zeros(1,size(C1,2)-numofvariables);
endwhile


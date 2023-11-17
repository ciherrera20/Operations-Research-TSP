param n:=3 integer > 0;
set S := 0 .. n - 1;
set SS := 0 .. 2**n - 1;
set POW {k in SS} := {i in S: (k div 2**i) mod 2 = 1};

param a:= card(S);
param b:= card(SS);
param c:= card(POW[0]);
param d:= card(POW[1]);
param e:= card(POW[2]);
param f:= card(POW[3]);
param g:= card(POW[4]);
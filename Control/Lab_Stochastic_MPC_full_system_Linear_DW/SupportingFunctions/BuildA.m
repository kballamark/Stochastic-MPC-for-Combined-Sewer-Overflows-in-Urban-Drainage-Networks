function [A] = BuildA(NumberOfStates,p,phi,DeltaT)
%BUILDB Returns the A matrix for the two tank topology with NumberOfStates
%   The first tank is included in the A matrix. dim(p) = (1,5) and
%   dim(phi) = (1,2)

A = casadi.MX.zeros(NumberOfStates,NumberOfStates);

A(1,:) = [1, zeros(1,NumberOfStates-1)];

A(2,:) = [0, 1 - p(2) * DeltaT, p(3) * DeltaT, zeros(1,NumberOfStates-3)]; 

for index = 3:1:NumberOfStates-2;
A(index,:) = [zeros(1,index-2), p(2) * DeltaT, 1 - ( p(2) + p(3) ) * DeltaT,...
             p(3) * DeltaT, zeros(1,NumberOfStates-index-1)];
end

A(NumberOfStates-1,:) = [zeros(1,NumberOfStates-3), p(2)* DeltaT,...
                        1 - ( p(5) + p(3) ) * DeltaT , 0]; %Last pipe section
A(NumberOfStates,:)   = [zeros(1,NumberOfStates-2), phi(2) * p(5) / p(1)...
                        * DeltaT, 1]; %Tank
end


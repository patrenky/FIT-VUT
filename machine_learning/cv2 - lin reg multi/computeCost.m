function [J] = computeCost(X,y,theta)
%% implementujte vypocet hodnotici funkce J pro danou hypotezu h a ucici mnozinu X,y
m = length(y);
% J = 0;

h = X * theta;
    % 47x3 * 3x1 = 47x1
J = sum((h - y) .^2) / (2 * m);

end
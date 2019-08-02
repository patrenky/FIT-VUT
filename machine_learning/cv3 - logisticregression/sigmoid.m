function [g] = sigmoid(z)
%SIGMOID spocte hodnoty funkce sigmoid
%   

% na vstupu muze byt cislo, vektor, nebo matice, promenna z

% nastavte korektne navratovou promennou g 
g = zeros(size(z));

% ====================== YOUR CODE HERE ======================

g = 1 ./ (1 + exp(-z));

% =============================================================

end

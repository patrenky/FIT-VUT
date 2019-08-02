function g = sigmoid(z)
%SIGMOID Compute sigmoid functoon
%   J = SIGMOID(z) computes the sigmoid of z.

% na vstupu muze byt cislo, vektor, nebo matice, promenna z

% nastavte korektne navratovou promennou g 
g = zeros(size(z));

% ====================== YOUR CODE HERE ======================

g = 1 ./ (1 + exp(z*(-1)));


% =============================================================

end

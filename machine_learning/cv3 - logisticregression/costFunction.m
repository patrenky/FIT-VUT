function [J, grad] = costFunction(theta, X, y)
%COSTFUNCTION Compute cost and gradient for logistic regression
% na vstupu
% theta - inicializovany sloupcovy vektor hledanych parametru
% X - matice, radky jsou jednotlive prvky trenovaci mnoziny, jiz je
%     predrazen prvni sloupec obsahujici pouze jednicky
% y - sloupcovy vektor vysledku prijat(1)/neprijat(0)


% inicializace
m = length(y); % number of training examples

% musite korektne nastavit tyto dve promenne 
J = 0; %cislo
grad = zeros(size(theta)); %sloupcovy vektor gradientu, stejny pocet jako promennych theta

%theta 0, 1, 2 tj. [3 x 1]
% X [100 x 3] ...jiz byla predrazena nula
% y [100 x 1]

% ====================== YOUR CODE HERE ======================
%pokuste provest vypocet a)cyklem b)maticove

% J=...vyuzijte drive napsane funkce sigmoid
% grad=...

% a) cyklom
%for i = 1:m
%    z = theta(1) * X(i,1) + theta(2) * X(i,2) + theta(3) * X(i,3);
%    h_xi = sigmoid(z);
%    Ji = -y(i) * log(h_xi) - ( 1 - y(i) ) * log(1 - h_xi);
%    J = J + Ji;
%end
%J = (1/m) * J;

% b) maticovo
z = X * theta; % 100x3 * 3x1 = 100x1
h_xi = sigmoid(z); % 100x1
J = (1/m) * ( -y' * log(h_xi) - (1/y) * log(1-h_xi) );
%            1x100     100x1    1x100       100x1

grad = (1/m) * ( X' * (h_xi - y) );
%              3x100    100x1  =  3x1

% =============================================================

end

function [J, grad] = costFunctionReg(theta, X, y, lambda)
%COSTFUNCTION Compute cost and gradient for logistic regression
% with regularization
% na vstupu
% theta - inicializovany sloupcovy vektor hledanych parametru
% X - matice, radky jsou jednotlive prvky trenovaci mnoziny, jiz je
%     predrazen prvni sloupec obsahujici pouze jednicky
% y - sloupcovy vektor vysledku chip je ok(1)/chip neni ok(0)


% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly 
J = 0;
grad = zeros(size(theta));

% ====================== YOUR CODE HERE ======================
%pokuste provest vypocet maticove

%theta 0, 1, 2 ... tj. [28 x 1]
% X [118 x 28] ...jiz byla predrazena nula
% y [118 x 1]


% J maticov� 
theta_1n = theta(2:length(theta)); %vsechno krom 1. cisla = 27 prvku
z = theta' * X';
h_x = sigmoid(z);
J = (1/m) * ((-y)' * log(h_x)' - (1-y)' * log(1-h_x)') + (lambda/(2*m))*sum(theta_1n.^2);
      

% gradienty:
 g_n =  (1/m) * ((h_x - y') * X); %celkem 28 gradientu [28x1] sloupcovy vekt stejne jako theta
 g0 = g_n(1);
 g_n = g_n(2:end);
 n = length(g_n);
 g_n = g_n' + (lambda/n) * theta_1n;
 grad = [g0; g_n];
% =============================================================

end

function [J, grad] = lrCostFunction(theta, X, y, lambda)
% funkce na vstupu dostane
% 1. theta - vychozi hodnoty hledanych parametru
% 2. matici X - trenovaci mnozina s predrazenymi jednickami v prvnim
%               sloupci
% 3. klasifikace vstupu X - jiz musi obsahovat pouze nuly a jednicky

% funkce vraci hodnotu hodnotici funkce J a prislusnych gradientu

% Je nezbytne nutne, aby jste vypocet implementovali maticove.

% bude se hodit
m = length(y); % number of training examples

% nasledujici promenne musite nastavit korektne
J = 0;
grad = zeros(size(theta));

%% ====================== YOUR CODE HERE ======================
% dobry vychozi bod je implementace teze funkce z minulych cviceni, kde
% jsme ale nepouzili regularizaci, zde ji pouzit musite

% J s regularizaci
theta_1n = theta(2:length(theta));
z = theta' * X';
h_x = sigmoid(z);
J = (1/m) * ((-y)' * log(h_x)' - (1-y)' * log(1-h_x)') + (lambda/(2*m))*sum(theta_1n.^2);
      

% grad pro J s regularizaci
g_n =  (1/m) * ((h_x - y') * X);
g0 = g_n(1);
g_n = g_n(2:end);
n = length(g_n);
g_n = g_n' + (lambda/n) * theta_1n;
grad = [g0; g_n];

      
% =============================================================

end

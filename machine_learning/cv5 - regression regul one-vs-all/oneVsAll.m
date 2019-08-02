function [all_theta] = oneVsAll(X, y, num_labels, lambda)
% tato funkce by mela najit parametry theta pro vsechny kalsifikatory
% klasifikatoru by byt tolik, kolik je uvedeno ve vstupnim parametru num_labels
% tj. 10 klasifikator, jeden ktery vraci pravdepodobnost ze se jedna o
% jednicku, dalsi ktery vraci pravdepodobnost ze se jedna o dvojku, atd.

% Je tedy zapotrebi zavolat desetkrat optimalizacni algoritmus fmincg
% tento algoritmus vyzaduje 3 parametry:
% 1. funkci, ktera vraci hodnotu cost function a hodnoty gradientu.
% 2. pocatecni hodnoty theta
% 3. options - parametry upravujici chovani funkce
% priklad volani:
% options = optimset('GradObj', 'on', 'MaxIter', 50);
% theta_partial = fmincg (@(t)(lrCostFunction(t, X, y_partial, lambda)), initial_theta, options);
% note: fmincg works similarly to fminunc, but is more efficient when we
%       are dealing with large number of parameters.


% bude se hodit:
m = size(X, 1); % pocet vzorku trenovaci mnoziny
n = size(X, 2); % 400, obrazky jsou 20x20

% musite nastavit korektne tuto promennou
all_theta = zeros(num_labels, n + 1); %tj. [10 x 401]

% do X predradime x0 tj. jednicky
X = [ones(m, 1) X];

% ====================== YOUR CODE HERE ======================

% 1. krok ukolu - implementujte funkci lrCostFunction.m, ktera vraci
%                 hodnotu J a hodnoty gradientu
% 2. krok ukolu - implementujte tento m-file

initial_theta = zeros(n + 1, 1);

for i = 1:num_labels
    y_partial = y == i;
    options = optimset('GradObj', 'on', 'MaxIter', 50);
    theta_partial = fmincg (@(t)(lrCostFunction(t, X, y_partial, lambda)), initial_theta, options);
    all_theta(i,:) = theta_partial';
end

% =========================================================================


end

function p = predict(theta, X)
% na vstupu jsou naucene parametry theta a trenovaci data X
% funkce vraci pro kazdy radek matice X hodnotu 0 nebo 1
% tj. pro kazdy radek X je nutne zjistit pravdepodobnost prijeti, a
% pokud je tato pravdepodobnost vyssi nebo rovna 0.5 tak vratit 1,
% jinak vratit 0.


m = size(X, 1); % pocet trenovacich vzorku

% promennou p je potreba nastavit, sloupcovy vektor nul a jednicek
p = zeros(m, 1);

% ====================== YOUR CODE HERE ======================
%zkuste maticove

%theta 0, 1, 2 tj. [28 x 1]
% X [100 x 28]
% p = ...

p = sigmoid(X * theta) >= 0.5;

% =========================================================================


end

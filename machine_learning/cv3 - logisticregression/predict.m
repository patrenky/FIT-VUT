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
%zkuste a)cyklem b)maticove

for i = 1:m
    prob = sigmoid([1 X(i,1) X(i,2)] * theta);
    if ( prob >= 0.5 ); p(i) = 1; else; p(i) = 0; end
end


% =========================================================================


end

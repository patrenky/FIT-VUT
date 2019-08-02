function p = predictOneVsAll(all_theta, X)
%metoda vraci vektor predikci (labels) pro vsechny vstupy X a naucene
%hodnoty Theta
%s vyhodou lze pouzit funkci max: [kolik,kde]=max(data,[],1)

m = size(X, 1);
%num_labels = size(all_theta, 1);

% musite korektne nastavit hodnotu vektoru p
p = zeros(size(X, 1), 1);

% do vstupnich dat musime predradit x0 (sloupec jednicek)
X = [ones(m, 1) X]; % [5000 x 401]

% ====================== YOUR CODE HERE ======================

% 1) nejprve zkuste predikovat jeden nahodne zvoleny vstup, tj. nahodne si
%    vyberte z matice X jeden radek a provedte predikci
% 2) rozsirte predchazejici ukol na celou matici X, tj. predikujte vsechna
%    vstupni data, reste maticovym zapisem 

[~, idx] = max(sigmoid(all_theta * X')); % [10 x 5000]
p = idx'; % [1 x 5000]'

% =========================================================================


end

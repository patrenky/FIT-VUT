function p = predict(Theta1, Theta2, X)
% zjistime si vysledky, ktere nam dava neuronova sit pro vstupni X


m = size(X, 1);
num_labels = size(Theta2, 1);

% =========================================================================

p = zeros(size(X, 1), 1);

X = [ones(m,1), X];

a1 = X'; % 401 x 5000
z2 = Theta1 * a1; % 25x401 * 401x5000 = 25 x 5000
a2 = sigmoid(z2); % 25 x 5000

sloupcu = size(a2, 2);
a2 = [ones(1, sloupcu); a2]; % 26 x 5000

z3 = Theta2 * a2; % 10x26 * 26x5000 = 10 x 5000
a3 = sigmoid(z3); % 10 x 5000

[~, idx] = max(a3); % 1 x 5000
p = idx';

% =========================================================================


end

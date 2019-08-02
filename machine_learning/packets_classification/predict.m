function p = predict(Theta1, Theta2, X, y)

% pocet zaznamu dat
m = size(X, 1);

% vektor predikci pro vsechny vstupy X
p = zeros(size(X, 1), 1);

% forward propagation
h1 = sigmoid([ones(m, 1) X] * Theta1');
h2 = sigmoid([ones(m, 1) h1] * Theta2');

[~, p] = max(h2, [], 2);

fprintf('Training set accuracy: %f\n', mean(double(p == y)) * 100);

end

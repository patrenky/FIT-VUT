function p = predict(Theta1, Theta2, X)
% implementace forward propagation, na vstupu mame naucene 
% vahy Theta1 a Theta2 a vstupy X

% bude se hodit
m = size(X, 1);
num_labels = size(Theta2, 1);

% promennou p musite nastavit korektne, vektor predikci pro vsechny vstupy X
p = zeros(size(X, 1), 1);

% ====================== YOUR CODE HERE ======================

% ke vstupnim neuronum predradime bias
X = [ones(m,1), X];

%ujasnete si rozmery techto matic:
%X [5000 x 401]
%Theta1 [ 25 x 401 ]
%Theta2 [ 10 x 26 ]

%forward propagation:

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

function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION implementuje 3-vrstvou neuronovou sit
% implementujte obecne, nejen pro vrstvy o velikost 400-25-10
% na vstupu jsou:
%    nn_params - hodnoty theta1 a 2 spojene do jednoho vektoru 
%    input_layer_size - pocet neuronu vstupni vrstvy (400 + 1)
%    hidden_layer_size - pocet neuronu skryte vrstvy (25 + 1)
%    num_labels - pocet moznych klasifikaci (10)
%    X,y - trenovaci mnozina (5000 x 400) a (5000 x 1)
%    lambda - parametr regularizace
%na vystupu jsou:
%   J - hodnota hodnotici funkce s regularizaci (pro dane vstupni theta)
%   grad - hodnota gradientu pro J s regularizaci, jako vektor

%% Rozbaleni do matic a prvotni inicializace:

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% pocet vzorku
m = size(X, 1);
         
% je nutne nastavit tyto promenne:
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

%% ====================== YOUR CODE HERE ======================
% KROK 1/3: Implementace feedforward a nasledny vypocet J bez regulariace

X = [ones(m,1), X]; %predradim bias do prvni vrstvy

a1 = X'; % 401 x 5000
z2 = Theta1 * a1; % 25x401 * 401x5000 = 25 x 5000
a2 = sigmoid(z2); % 25 x 5000

sloupcu = size(a2, 2);
a2 = [ones(1, sloupcu); a2]; % 26 x 5000

z3 = Theta2 * a2; % 10x26 * 26x5000 = 10 x 5000
a3 = sigmoid(z3); % 10 x 5000

%pro vsechny trenovaci data forward propagation: a3 = ....

%vypocet J pres vsechny trenovaci vzorky bez regularizace
% for i = 1:m
%   Jpart = ...
%   J = J + part;
% end;
% J = J/m; %..bez regularizace

J = 0;
K = max(y); % odpovida poctu vystupnych neuronu
y_i = zeros(1,K); % inicializace, aby neprobihala stale dookola
for i = 1:m
    hx_i = a3(:,i); % pst pro i-ty vzorek [10x1]
    y_i = (1:K) == y(i); % vektor nul a jedne jednicky dle label i-teho vzorku
    Jpart = (-y_i) * log(hx_i) - (1-y_i) * log(1-hx_i);
    %        1x10      10x1        1x10       10x1
    J = J + Jpart;
end
J = J/m; % ...bez regularizace


%% KROK 2/3: Implementace backpropagation a nasledny vypocet
%            gradientu bez regularizace

% Doporuceni: provedte implementaci backpropagation ve smysce for
% Pozor y obsahuje cisla 1 az 10, musite si vzdy pripravit y tak, aby
% obsahovalo jednicky a nuly 

DELTA2 = zeros(hidden_layer_size, input_layer_size+1); % 25x401
DELTA3 = zeros(K, hidden_layer_size+1); % 10x26

for t = 1:m        %pres vsechny vzorky
    a1 = X(t,:)'; % 401 x 5000
    z2 = Theta1 * a1; % 25x401 * 401x5000 = 25 x 5000
    a2 = sigmoid(z2); % 25 x 5000
    sloupcu = size(a2, 2);
    a2 = [ones(1, sloupcu); a2]; % 26 x 5000
    z3 = Theta2 * a2; % 10x26 * 26x5000 = 10 x 5000
    a3 = sigmoid(z3); % 10 x 5000

    % delta pro posledni vrstvu
    yt = (1:K) == y(t);
    delta3 = a3 - yt';
    
    %delta pro posledni vrstvu
    gz2 = a2 .* (1 - a2); % 26x5000
    delta2 = Theta2' * delta3 .* gz2;
    %        26x10    10x5000  26x5000 = 26x5000
    
    % kumulace poruch
    DELTA2 = DELTA2 + delta2(2:end,:) * a1';
    %        25x401      25x5000    5000x401
    DELTA3 = DELTA3 + delta3(:,:) * a2';
end

D2 = DELTA2 ./ m;
D3 = DELTA3 ./ m;


%% KROK 3/3: Implementace J s regulariazaci a gradientu s regularizaci

% vypocet regulariazacni casti J
% Jreg =
th1 = Theta1(:,2:end);
th2 = Theta2(:,2:end);
Jreg = (lambda / (2*m)) * (sum(sum(th1.^2)) + sum(sum(th2.^2))); 
                      % sum najprv zcita stlpce matice, dalsi sum riadok (1. sum)

% K drive spoctenemu J bez regul. nyni pouze prictu a mam vysledne J
J = J + Jreg;

% gradienty
% Mame-li implementovan backpropagation, staci k vyslednemu D1 a D2 pricist
% regularizaci:
D2(:,2:end) = D2(:,2:end) + (lambda/m) .* Theta1(:,2:end);
D3(:,2:end) = D3(:,2:end) + (lambda/m) .* Theta2(:,2:end);

Theta1_grad = D2;
Theta2_grad = D3;

% -------------------------------------------------------------

% =========================================================================
% Unroll gradients - spoctene theta ulozim do jedineho vektoru
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end

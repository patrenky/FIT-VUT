function [J, grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   output_layer_size, ...
                                   X, y, m, lambda)
%% Rozbaleni do matic a prvotni inicializace

Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 output_layer_size, (hidden_layer_size + 1));

% hodnota hodnotici funkce s regularizaci (pro dane vstupni theta)
J = 0;


%% Implementace feedforward a nasledny vypocet J bez regulariace

% predrazeni biasu do prvni vrstvy
X = [ones(m,1), X];

% prvni vrstva neuronove site - vstupni vrstva
a1 = X';

% druha vrstva neuronove site - skryta vrstva
z2 = Theta1 * a1;
a2 = sigmoid(z2);

% predrazeni biasu do druhe vrstvy
a2 = [ones(1, size(a2, 2)); a2];

% treti vrstva neuronove site - vystupni vrstva
z3 = Theta2 * a2;
a3 = sigmoid(z3);

% vypocet hodnotici funkce J bez regularizace
for i = 1:m
    % pst pro i-ty vzorek
    hx_i = a3(:,i);
    % vektor nul a jedne jednicky dle label i-teho vzorku
    y_i = (1:output_layer_size) == y(i);
    Jpart = (-y_i) * log(hx_i) - (1-y_i) * log(1-hx_i);
    J = J + Jpart;
end
J = J/m;


%% Implementace backpropagation a nasledny vypocet gradientu bez regularizace

% poruchy na druhe a treti vrstve neuronove site = rozdil mezi skutecnym
% a ocekavanym vystupem neuronu
DELTA2 = zeros(hidden_layer_size, input_layer_size+1);
DELTA3 = zeros(output_layer_size, hidden_layer_size+1);

for t = 1:m
    % a1 - aktivacni funkce prvni vrstvy
    % pomoci forward prop. spocteme aktivacni funkce a2, a3 (po posledni vrstvu)
    a1 = X(t,:)';
    z2 = Theta1 * a1;
    a2 = sigmoid(z2);
    a2 = [ones(1, size(a2, 2)); a2];
    z3 = Theta2 * a2;
    a3 = sigmoid(z3);

    % vypocet je nutne provadet od posledni vrstvy smerem k prvni
    % delta pro posledni vrstvu
    yt = (1:output_layer_size) == y(t);
    delta3 = a3 - yt';
    
    % back prop. spocte poruchy pro vsechny predchozi vrstvy
    % delta pro druhou vrstvu
    gz2 = a2 .* (1 - a2);
    delta2 = Theta2' * delta3 .* gz2;
    
    % spocteme kumulace poruch
    DELTA2 = DELTA2 + delta2(2:end,:) * a1';
    DELTA3 = DELTA3 + delta3(:,:) * a2';
end

% gradienty hodnotici funkce
D2 = DELTA2 ./ m;
D3 = DELTA3 ./ m;


%% Implementace J s regulariazaci a gradientu s regularizaci

% vypocet regulariazacni casti J
th1 = Theta1(:,2:end);
th2 = Theta2(:,2:end);
Jreg = (lambda / (2*m)) * (sum(sum(th1.^2)) + sum(sum(th2.^2))); 

% k drive spoctenemu J bez regul. nyni prictu J s regularizaci
J = J + Jreg;

% mame-li implementovan backpropagation, staci k vyslednym gradientum pricist regularizaci
D2(:,2:end) = D2(:,2:end) + (lambda/m) .* Theta1(:,2:end);
D3(:,2:end) = D3(:,2:end) + (lambda/m) .* Theta2(:,2:end);

% hodnota gradientu pro J s regularizaci, jako vektor
grad = [D2(:) ; D3(:)];


end

clc; clear; close all;


%% Nacteni dat a inicializace promennych

fprintf('Data initialization\n')

[train_input, train_output] = loadData('./dataset_train.csv');
[test_input, test_output] = loadData('./dataset_test.csv');

% ulozeni rozmeru vstupnich dat
num_records = size(train_input, 1);
num_features = size(train_input, 2);

% inicializace rozmeru neuronove site
input_layer_size = num_features; % pocet atributu na vstupu
hidden_layer_size = 10; % pocet neuronu skryte vrstvy
output_layer_size = size(unique(train_output), 1); % pocet unikatnych hodnot, jakych muze nabyvat Y

% inicializace lambda = parametr regularizace
lambda = 0.01;

% inicializace vah
initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer_size);
initial_Theta2 = randInitializeWeights(hidden_layer_size, output_layer_size);
initial_nn_params = [initial_Theta1(:); initial_Theta2(:)];

               
%% Trenovani neuronove site

fprintf('Train neural network\n')

% maximalni pocet iteraci pouzite optimalizacni funkce
options = optimset('MaxIter', 50);

% volani funkce, ktera pocita J a gradienty
costFunction = @(p) nnCostFunction(p, input_layer_size, ...
                                   hidden_layer_size, ...
                                   output_layer_size, ...
                                   train_input, train_output, ...
                                   num_records, lambda);

% spustime hledani minima J
[nn_params, cost] = fmincg(costFunction, initial_nn_params, options);

% spoctene Theta dostaneme pohromade jako jediny vektor, poskladame si opet matice
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 output_layer_size, (hidden_layer_size + 1));

             
%% Vizualizace

plotCostFunction(cost);


%% Predikce u testovacich dat

predict(Theta1, Theta2, test_input, test_output);


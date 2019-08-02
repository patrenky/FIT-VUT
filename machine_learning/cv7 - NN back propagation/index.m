%% Neural Network back propagation algorithm

% Initialization
clear ; close all; clc

%% Nacteni trenovacich dat dat a jejich zobrazeni 
% --- Ukol1: ujasnete si velikosti X,y,theta a jednotlivych vrstev site ---

% nastaveni velikosti site:
input_layer_size  = 400;  % 20x20px velikost vstupnich obrazu rucne psanych cislic
hidden_layer_size = 25;   % 25 skrytych neuronu na druhe vrstve
num_labels = 10;          % 10 labels, 1 az 10, label 10 je cislice 0

% nacteni trenovacich dat
load('ex4data1.mat'); %vytvori X y 
m = size(X, 1);       

% nahodne vybereme 100 obrazku a zobrazime
sel = randperm(size(X, 1));
sel = sel(1:100);
displayData(X(sel, :));

%nacteme prednaucene theta do Theta1 and Theta2
% (jen aby jste si mohli prubezne kontrolovat vysledky svych ukolu)
load('ex4weights.mat'); %vytvori Theta1
                        %a Theta2
nn_params = [Theta1(:) ; Theta2(:)]; % Unroll parameters 

fprintf('Program paused. Press enter to continue.\n');
% pause;

%% Feedforward
% --- Ukol 2: spocitejte hodnotu hodnotici funkce J (bez regularizace)
%             v nnCostFunction.m implementujte KROK 1

% prozatim nastavime parametr regularizace na 0 a rim Regul. vypneme
lambda = 0;

J = nnCostFunction(nn_params, input_layer_size, hidden_layer_size, ...
                   num_labels, X, y, lambda);

fprintf(['Hodnota J pro vahy nahrane z ex4weights.mat: %f '...
         '\n(melo by vam vyjit 0.287629)\n'], J);

fprintf('\nProgram paused. Press enter to continue.\n');
% pause;

%% Regularizace hodnotici funkce
% --- Ukol 3: spocitejte hodnotu hodnotici funkce J (s regularizaci)
%             v nnCostFunction.m implementujte KROK 3 ...Jreg=

fprintf('\nKontrola Hodnotici funkce s Regulariaci ... \n')

% pro kontrolu si nastavime regularizaci na 1
lambda = 1;

J = nnCostFunction(nn_params, input_layer_size, hidden_layer_size, ...
                   num_labels, X, y, lambda);

fprintf(['Hodnota J pro vahy nahrane z ex4weights.mat: %f '...
         '\n(melo by vam vyjit 0.383770)\n'], J);

fprintf('Program paused. Press enter to continue.\n');
pause;

%% Sigmoid Gradient  
% --- implementace gradientu pro sigmoidu v sigmoidGradient.m

fprintf('\nEvaluating sigmoid gradient...\n')

g = sigmoidGradient([1 -0.5 0 0.5 1]);
fprintf('Sigmoid gradient evaluated at [1 -0.5 0 0.5 1]:\n  ');
fprintf('%f ', g);
fprintf('\n\n');

%% Inicializace vychozich theta
% --- Ukol 4: provedte inicializaci vah na nahodne male hodnoty ve funkci
%             randInitializeWeights.m

fprintf('\nInicializace vah neuronove site ...\n')

initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer_size);
initial_Theta2 = randInitializeWeights(hidden_layer_size, num_labels);

% Unroll parameters
initial_nn_params = [initial_Theta1(:) ; initial_Theta2(:)];

%% Backpropagation 
% --- Ukol 5: implementujte ucici algoritmus BackPropagation neuronove site
%             v nnCostFunction.m implementujte KROK 2 - vypocet gradientu 
%             bez regularizace 

fprintf('\nKontrola Backpropagation... \n');

%  kontrola implementace pomoci numerickeho vypoctu gradientu:
checkNNGradients;

fprintf('\nProgram paused. Press enter to continue.\n');
pause;

%% Vypocet gradientu s regularizaci
% --- Ukol 6: v nnCostFunction.m implementujte KROK 3 - vypocet gradientu 
%             s regularizaci 

fprintf('\nKontrola Backpropagation s Regularizaci ... \n')

%  kontrola implementace pomoci numerickeho vypoctu gradientu:
lambda = 3;
checkNNGradients(lambda);

% kontrola J
debug_J  = nnCostFunction(nn_params, input_layer_size, ...
                          hidden_layer_size, num_labels, X, y, lambda);

fprintf(['\n\nCost at (fixed) debugging parameters (w/ lambda = 10): %f ' ...
         '\n(this value should be about 0.576051)\n\n'], debug_J);

fprintf('Program paused. Press enter to continue.\n');
pause;


%% Trenovani neuronove site
% Nyni jiz mate naimplementovane vse potrebne a muze spusti uceni neuronove
% site. K hledani minima hodnotici funkce pouzijeme funkci fmincg, ktera
% je silne optimalizovana a dava pro nase potreby dobre vysledky.

fprintf('\nTrenovani Neuronove site... \n')

%  Muzete si zkusit nastavit maximalni pocet iteraci pouzite optimalizacni
%  funkce, mirne navyseni pomuze..
options = optimset('MaxIter', 50);

%  zkuste ruzne hodnoty regularizacniho parametru
lambda = 1;

% pripravime si volani nasi funkce, ktera pocita J a gradienty
costFunction = @(p) nnCostFunction(p, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, X, y, lambda);

%spustime hledani minima J:
[nn_params, cost] = fmincg(costFunction, initial_nn_params, options);

% spoctene Theta dostaneme pohromade jako jediny vektor, poskladame si
% opet matice:
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

fprintf('Program paused. Press enter to continue.\n');
pause;


%% Zobrazeni vah Theta1
%  pro zajimavost si muzeme vykreslit jake features se naucila neuronova
% sit na skryte vrstve:

fprintf('\nVisualizing Neural Network... \n')

displayData(Theta1(:, 2:end));

fprintf('\nProgram paused. Press enter to continue.\n');
pause;

%% Vypocet predikce:
% --- Ukol 7: opet si spustime predikci na trenovaci mnozine a porovname
%             s ocekavanymi vysledky, implementujte funkci predict

pred = predict(Theta1, Theta2, X);
fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == y)) * 100);




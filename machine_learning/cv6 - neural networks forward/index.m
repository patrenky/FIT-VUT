%% klasifikátor cislic z obrazu pomoci neuronove site 
% implementace 3vrstve neuronove site, bez uciciho algoritmu

clear ; close all; clc

% nastaveni vstupnich parametru - pouzijeme 3vrtvou neuronovou sit:
input_layer_size  = 400;  % 20x20 vstupni obrazky maji 20 x 20 px
hidden_layer_size = 25;   % 25 neuronu na druhe vrstve (skryta vrstva)
num_labels = 10;          % 10 labels, 1 az 10, label 10 je cislice 0


%% Nacteni a zobrazeni dat - Ukol 1 ujasnete si rozmery jednotlivych promennych

load('ex3data1.mat'); % automaticky vytvori vstupni matici X a vektor y
m = size(X, 1);

% nahodne vyberu 100 obrazku a zobrazim
sel = randperm(size(X, 1));
sel = sel(1:100);
displayData(X(sel, :));

fprintf('Program paused. Press enter to continue.\n');
pause;
%% V tomto ukolu neimplementujeme ucici algoritmus, naucene vahy neuronove 
% site dostavame jako vstup - Ukol 2 ujasnete si rozmery Theta1 a Theta2 

% ulozeni naucenych vah do matic theta1 a theta2:
load('ex3weights.mat');

%% Implementace vypoctu predikce naucene neuronove site - Ukol 3
% implementujte funkci predict, ktera vraci odhady pro vsechna
% vstupni data X

pred = predict(Theta1, Theta2, X);

fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == y)) * 100);

fprintf('Program paused. Press enter to continue.\n');
pause;

%% Vizualni kontrola predikce vs. realita
% v cyklu volame funkci predikt, vzdy pro klasifikaci jednoho 
% nahodne vybraneho vstupu(obrazku)

%  Randomly permute examples
rp = randperm(m);

for i = 1:m
    % Display 
    fprintf('\nDisplaying Example Image\n');
    displayData(X(rp(i), :));

    pred = predict(Theta1, Theta2, X(rp(i),:));
    fprintf('\nNeural Network Prediction: %d (digit %d)\n', pred, mod(pred, 10));
    
    % Pause
    fprintf('Program paused. Press enter to continue.\n');
    pause;
end


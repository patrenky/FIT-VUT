%% logisticka regrese one-vs-all, klasifikace obrazu napsane cislice

clear ; close all; clc


%n  = 400;        % pocet features je 400, protoze vstupni obraz je 20x20 px
num_labels = 10;  % 10 labels, od 1 do 10, label 1 znaci cislici 1, atd.,
                  % label deset znaci cislici 0
                          
%% Nacteni a zobrazeni dat - Ukol 1: ujasnete si rozmer matice X a obsah vektoru y
% vstupni dataset obsahuje rucne psane cislice, kazdy obrazek ma 20x20 px
% data jsou prednachystana v souboru ex3data1.mat jako promenne X a y

load('ex3data1.mat'); % trenovaci data jsou automaticky ulozena do promennych X, y
m = size(X, 1); %5000 trenovacich vzorku

% nahodne vyberu 100 obrazku a zobrazim si je
rand_indices = randperm(m);
sel = X(rand_indices(1:100), :);
displayData(sel);

fprintf('Program paused. Press enter to continue.\n');
pause;
%% Ukol 2: Implementace logisticke regrese s regularizaci one-vs-all,
% ktera rozezna ze vstupniho obrazu o jake cislo se jedna
% Ukol 2: naimplementujte metodu oneVsAll, ktera nelezne hodnoty theta pro
% vsechny dilci klasifikatory - dalsi ukol uvnitr metody

lambda = 0.1; % parametr regularizace
[all_theta] = oneVsAll(X, y, num_labels, lambda);

fprintf('Program paused. Press enter to continue.\n');
pause;
%% Posouzeni presnosti predikce na trenovacich datech - Ukol 3
% implementujte metodu predictOneVsAll, ktera vraci vektor s jednotlivymi
% labels, tj. hodnoty 1 az 10, pro vsechny vstupni data X

pred = predictOneVsAll(all_theta, X);
fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == y)) * 100);
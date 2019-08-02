clear ; close all; clc;

%% sigmoida - Ukol1 napiste funkci sigmoid
z = [-10:0.1:10];
y = sigmoid(z);
%figure;
%plot(z,y);
clear z, clear y;

%% data a inicializace - Ukol2 napiste funkci plotData

%nacteni dat - vysledky dvou testu a informace o tom zda studenta
%  prijmout(y==1) ci nikoliv(y==0)
data = load('ex2data1.txt');
X = data(:, [1, 2]); y = data(:, 3);

%zobrazeni dat
%plotData(X, y);

%sestaveni cost function 
[m, n] = size(X); 
    %m pocet prvku v trenovaci mnozine
    %n pocet features

% predrazeni x0 do features, ..zvysim n o 1
X = [ones(m, 1) X];

% pocatecni inicializace parametru theta, je jich celkem n+1
initial_theta = zeros(n + 1, 1);

%% vypocet cost function a prislusnych gradientu - Ukol3
% napiste funkci, ktera vraci hodnotu Costfunction a gradientu
[cost, grad] = costFunction(initial_theta, X, y);

%% optimalizace - hledani minima, nikoliv gradientni metodou, ale
%  pomoci funkce fminunc

%  nastaveni parametru funkce fminunc
options = optimset('GradObj', 'on', 'MaxIter', 400);
    %nastavujeme dva parametry GradObj na on - tim rikame, ze nase funkce
    % vraci nejen hodnotu cost ale i gradienty
    % MaxIter nastavujeme na 400, tim rikame, ze bude provedeno maximalne
    % 400 iteraci

%  vlastni volani funkce fminunc, ktera spocte hledane theta a nalezene
%  minimum hodnotici funkce
%  t je pouzito jako parametru, ktery predava theta do kazdeho dlasiho
%  volani
[theta, cost] = fminunc(@(t)(costFunction(t, X, y)), initial_theta, options);

%% plot decision boundary

plotDecisionBoundary(theta, X, y); %samostudium v pripade zajmu

%% predikce a presnost - Ukol4 napiste funkci predict(theta,X)
% Pouzijte naucene theta pro rozhodnuti o prijeti studenta,
% ktery obdrzel na 1.test 45 bodu a na druhy test 85 bodu

prob = sigmoid([1 45 85] * theta);
fprintf(['Pro stedenta s vysledky 45 and 85 bodu predikujeme ' ...
         'pravdepodobnost prijeti: %f\n\n'], prob);

% jaka je presnost predikce pro trenovaci mnozinu
p = predict(theta, X);

fprintf('Train Accuracy: %f\n', mean(double(p == y)) * 100);

%% Logistic Regression with regularization

%% Inicializace, nacteni dat, zobrazeni dat - Ukol 1 zobrazte data
clear ; close all; clc

% nacteni dat - vysledek 1. testu chipu, vysledek druheho testu chipu,
% je kvalita chipu akceptovatelna? y==0 neni, y==1 je akceptovatelna

data = load('ex2data2.txt');
X = data(:, [1, 2]); y = data(:, 3);
plotData(X, y);

%% zavedeni 'slozite' hypotezni funkce, ktera ma spoustu features

% pridame dalsi features, pouze vyssi mocniny x1 a x2, tedy nepridavame
% nejake nove informace

% do X pridame nekolik novych sloupcu a zaroven take predradime 1.sloupec
% jednicek, takze X bude obsahovat tyto sloupce:
% [1 x1 x2 x1^2 x1x2 x2^2 x1^3 ... x2^6 ] celkem 28 slupcu
% nase hypoteza je polynom 6. stupne
X = mapFeature(X(:,1), X(:,2)); %X je[118 x 28]


%% vypocet cost function a prislusnych gradientu - Ukol 2
% napiste funkci, ktera vraci hodnotu Costfunction a gradientu a
% zahrnuje regularizaci

% nastaveni vychozich hodnot theta
initial_theta = zeros(size(X, 2), 1);

% nastaveni parametru regularizace
lambda = 0.01;                        

% napiste funkci, ktera vraci hodnotu Costfunction a gradientu
[cost, grad] = costFunctionReg(initial_theta, X, y, lambda);

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

% Optimize
[theta, J, exit_flag] = ...
	fminunc(@(t)(costFunctionReg(t, X, y, lambda)), initial_theta, options);

%% plot decision boundary - Ukol 3 vykreslete nekolik grafu s ruznou hodnotou 
% lambda, sledujte jak se meni decision boundary,
% pro jake hodnoty lambda se jedna o underfitting a pro jake o overfitting
plotDecisionBoundary(theta, X, y);
hold on
title(sprintf('lambda = %g', lambda))
hold off

%% jaka je presnost predikce pro trenovaci mnozinu - Ukol 4
% napiste funkci predict a pozorujte jak se meni presnost predikce se 
% zmenou parametru lambda

p = predict(theta, X);
fprintf('Train Accuracy: %f\n', mean(double(p == y)) * 100);



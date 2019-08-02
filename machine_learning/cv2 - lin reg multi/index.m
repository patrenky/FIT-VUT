%% vstupni data a jejich normalizace
clear;
clc;
%% import a zobrazeni dat
data = load('ex1data2.txt'); %tri sloupce rozloha bytu, pocet pokoju, cena bytu
X=data(:,1:2);  %hodnoty dvou features, tj. dva sloupce
y=data(:,3);    %ceny bytu, tj. treti slupec
m=size(data,1); %pocet vzorku

%ukol 1: doplnte funkci showData
% showData(X,y); 

%ukol2: implementujte normalizaci ((x-prumer)/smerodatOdchylka)
[X, mu, sigma] = featureNormalization(X);
%max(X) %min(X)

%z duvodu maticoveho vypoctu si pridam do features x0
X = [ones(m, 1) X]; %47x3 ..3 sloupce: jednicka, rozloha, pocet pokoju

%% gradientni metoda
alpha = 0.1; %??
num_iters = 100; %??
theta = zeros(3, 1); %h = theta0 x0 + theta1 x1 + theta2 x2 ...n==2

%ukol 3: implementujte gradientni metodu pro vypocet optimalnich hodnot theta
[theta, J_history] = gradDescMulti(X, y, theta, alpha, num_iters);

disp('vysledne argumenty') %sloupcovy vektor

%% prubeh vypoctu
% figure(2)
% plot(J_history,'-x')
% grid('on')
% xlabel('iterace no.')
% ylabel('hodnotici funkce')

%% kontrola vypoctu
% spoctete cenu bytu pro novy byt
%1. byt (rozloha bytu, pocet pokoju, cena): 1268, 3, 259900
%2. byt (rozloha bytu, pocet pokoju, cena): 1239, 3, 229900

x15 = [1268, 3];
x15 = (x15 - mu) ./ sigma; % 1x2
x15 = [1, x15]; % 1x3
h = x15 * theta; % 1x3 * 3x1 = 1x1
odchylka = h - 259900; % odchylka od ceny v zadani

%% D.cv. implementujte funkci, ktera vyuzije nalezenou hypotezu pro vypocet
% cen bytu, ktere nejsou zahrnuty v trenovaci mnozine
% nemame takova data, proto na vstupu pouzijeme matici data
kontrola(data,theta,mu,sigma)
function [X_norm, mu, sigma] = featureNormalization(X)
%% funkce normalizuje jednotlive features
% pro normalizaci pouzijte ((x-prumer)/smerodatOdchylka)
% vstup: X dva sloupce, m radku
% vystup:
%   X_norm  obsahuje normalizovane hodnoty, stejna velikost jako X
%   mu      je prumer, velikost 1x2, pro kazdy atribut jeden prumer
%   sigma   smerodatna odchylka == standard deviation, velikost 1x2
% 95% hodnot lezi mezi prumer +/- 2sigma

%inicializace
X_norm = X;                     % size m x 2
% mu = zeros(1, size(X, 2));      % 1x2 prumer
% sigma = zeros(1, size(X, 2));   % 1x2 standart deviation

%vypocet mi a sigma
mu = mean(X);       %prumerna hodnota, 1x2
sigma = std(X);     %standard deviation, smerodatna odchylka, 1x2

%rozkopirovani mi a sigma do matice stejne velke jako vstup X
multiMu = repmat(mu, size(X, 1), 1); %nakopirujte prumer m-krat pod sebe, 47x2
multiSigma = repmat(sigma, size(X, 1), 1); %nakopirujte sigma m-krat pod sebe

%vypocet normalizace
X_norm = (X_norm  - multiMu) ./ multiSigma; % 47x2

end
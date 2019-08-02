function [X_norm, mi, sigma] = featureNormalization(X)

X_tmp = X;

% prumerna hodnota
mi = mean(X);
% smerodajna odchylka
sigma = std(X);

% rozkopirovani mi a sigma do matice stejne velke jako vstup X
multi_mi = repmat(mi, size(X,1), 1);
multi_sigma = repmat(sigma, size(X,1), 1);

% vypocet normalizace
X_norm = (X_tmp - multi_mi) ./ multi_sigma;

end
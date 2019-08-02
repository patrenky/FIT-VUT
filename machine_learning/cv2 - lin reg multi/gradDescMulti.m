function [theta, J_history] = gradDescMulti(X, y, theta, alpha, num_iters)
%% implementujte gradientni metodu pro vypocet optimalnich hodnot theta
% soucasti vypoctu je volani funkce pro vypocet hodnotici funkce computeCost

%theta      3x1 je sloupcovy vektor, vsechny hodnoty jsou inicializovane na nula
%X          47x3 ... jednicka, rozloha, pocet pokoju
%alpha      learning rate
%num_iters  pozadovany pocet iteraci

m = length(y);  %pocet vzorku
J_history = zeros(1, num_iters); %bude me zajimat vykresleni prubehu vypoctu hodnotici funkce

for iter = 1:num_iters
    
    h = X * theta; % 47x3 * 3x1 = 47x1 
      %..hodnota hypotezni funkce pro vsechna trenovaci data v dane iteraci
    
    argument = ( h - y )' * X;
                % 1*47   * 47x3 = 1x3
    
    theta = theta - alpha * ( 1/m ) * argument';
            % 3x1 - 1x1   *  1x1    * 3x1 = 3x1
    
    %ukol: doplnte implementaci funkce computeCost
    J_history(iter) = computeCost(X,y,theta); 
end

end

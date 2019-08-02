function []=kontrola(data,theta,mu,sigma)
%% D.cv. implementujte funkci, ktera vyuzije nalezenou hypotezu pro vypocet
% cen bytu, ktere nejsou zahrnuty v trenovaci mnozine
% nemame takova data, proto na vstupu pouzijeme matici data

rozloha = [0:1000:5000];
pokoje = [0:1:5];
m = length(rozloha);
cena = zeros(m,m);

for i = 1:m
    for j = 1:m
        x = [rozloha(i), pokoje(j)];
        x = (x - mu) ./ sigma;
        x = [1, x];
        cena(i,j) = x * theta;
    end
end

%vykreslete 3D graf ukazujici zavislost spoctene ceny na vstupnich
%atributech:
figure(3)
scatter3(data(:,1), data(:,2), data(:,3));
hold on
[x,y] = mashgrid(rozloha, pokoje);
surf(x,y,cena);
xlabel('rozloha')
ylabel('pocet pokoju')
zlabel('odhad ceny bytu')

end
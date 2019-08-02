function []=showData(X,y)
%% funkce ktera vykresli treninkovou mnozinu ve 3D
figure(1)
scatter3(X(:,1), X(:,2), y, 4);
xlabel('rozloha')
ylabel('pocet pokoju')
zlabel('cena bytu')

end
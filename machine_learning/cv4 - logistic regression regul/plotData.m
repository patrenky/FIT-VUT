function plotData(X, y)

figure;

% ====================== YOUR CODE HERE ======================
% vykreslete 2D graf vstupnich dat, na ose x vysledky prvniho testu,
% na ose y vysledky druheho testu
% je-li vysledek prijat (y==1) tak vykreslete znak krizek
% je-li vysledek neprijat (y==0) tak vykreslete znak kolecko
pos0 = find(y==0);
pos1 = find(y==1);
plot(X(pos1, 1), X(pos1, 2),'+', X(pos0, 1), X(pos0, 2), 'o')
% h = plot(...
% set(h(1),'LineWidth',1.5);
% set(h(2),'MarkerEdgeColor',[0 0 0]);
% set(h(2),'MarkerFaceColor',[1 1 0]);

% =========================================================================
xlabel('Microchip Test 1')
ylabel('Microchip Test 2')
legend('y = 1', 'y = 0')

end

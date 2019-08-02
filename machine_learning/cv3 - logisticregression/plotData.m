function plotData(X, y)

figure;

% ====================== YOUR CODE HERE ======================
% vykreslete 2D graf vstupnich dat, na ose x vysledky prvniho testu,
% na ose y vysledky druheho testu
% je-li vysledek prijat (y==1) tak vykreslete znak krizek cerne +k
% je-li vysledek neprijat (y==0) tak vykreslete znak kolecko zlute oy

%napoveda: pos = find(y==1); ulozi do promenne pos indexi radku, ve kterych
%je vysledek prijat

pos = find(y==1);
neg = find(y==0);

% pozitivny
plot(X(pos,1), X(pos,2), 'o');

hold on;

% negativny
plot(X(neg,1), X(neg,2), 'x');

%set(h(1),'LineWidth',1.5);
%set(h(2),'MarkerEdgeColor',[0 0 0]);
%set(h(2),'MarkerFaceColor',[1 1 0]);
xlabel('Exam 1 score')
ylabel('Exam 2 score')
legend('Admitted', 'Not admitted')

% =========================================================================


end

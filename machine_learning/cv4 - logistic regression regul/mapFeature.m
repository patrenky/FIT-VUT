function out = mapFeature(X1, X2)
% pridame dalsi features, pouze vyssi mocniny x1 a x2, tedy nepridavame
% nejake nove informace

% do X pridame nekolik novych sloupcu a zaroven take predradime 1.sloupec
% jednicek, takze X bude obsahovat tyto sloupce:
% [1 x1 x2 x1^2 x1x2 x2^2 x1^3 ... x2^6 ] celkem 28 slupcu
% nase hypoteza je polynom 6. stupne

% vstupni X1, X2 musi byt stejne velke vektory


degree = 6;
out = ones(size(X1(:,1)));
for i = 1:degree
    for j = 0:i
        out(:, end+1) = (X1.^(i-j)).*(X2.^j);
    end
end

end
function g = sigmoid(z)
% vytvoreni funkce sigmoid

g = zeros(size(z));
g = 1 ./ ( 1 + exp( -z ) );

end

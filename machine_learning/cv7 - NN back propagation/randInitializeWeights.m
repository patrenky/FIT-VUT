function W = randInitializeWeights(L_in, L_out)
% Funkce provadi inicilizaci vah v matici W, tato matice ridi vypocet mezi
% dvema vrstvami, na prvni je L_in neuronu, na druhe je L_out neuronu
% Vystupni matice W by proto mela mit velikost [L_out, 1 + L_in]

% ====================== YOUR CODE HERE ======================
% musite nastavit promennou W na nahodna <-0.12 , 0.12>
% Note: The first row of W corresponds to the parameters for the bias units
W = zeros(L_out, 1 + L_in);
epsilon = 0.12; %nebo sqrt(6)/sqrt(L_out + L_in);

W = (rand(L_out, 1 + L_in) * 2 * epsilon) - epsilon;

% =========================================================================
%W(1,:) = ones(1,1 + L_in);

end

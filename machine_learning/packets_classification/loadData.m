function [X, y] = loadData(dataset_path)

% funkce nacte data ze zadane cesty k csv souboru
table = readtable(dataset_path); % [ num_records x 27 ]
data = table2array(table);

% nasledne vybere atributy (X), potrebne pre uceni neuronove site:
% FROM_NODE numeric
% TO_NODE numeric
% PKT_TYPE enum
% PKT_SIZE numeric
% NUMBER_OF_PKT numeric
% NUMBER_OF_BYTE numeric
% NODE_NAME_FROM enum
% NODE_NAME_TO enum
% PKT_RATE numeric
% PKT_AVG_SIZE numeric
% PKT_DELAY numeric
X = [data(:, (4:7)), data(:, (10:13)), data(:, (18)), data(:, (20)), data(:, (22))];

% inicializace Y:
% PKT_CLASS enum
y = data(:, 27);

% normalizace dat
[X, ~, ~] = featureNormalization(X);

end


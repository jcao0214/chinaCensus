%% Load data (test)
clearvars;
filename = 'shandong';
[~ , ~ , ethnicity] = xlsread(['Data/' , filename , '_ethnicity.xlsx']);
[~ , ~ , inter] = xlsread(['Data/' , filename , '_inter.xlsx']);

%% Clean up ethnicity data
ethnicity_place = ethnicity(6 : end , 1);
ethnicity_place(cellfun(@(x) ~ischar(x) , ethnicity_place , 'un' , 1)) = {'a'};

% Columns

% data_col = 5;
% for temp_start = 11 : 12 : size(ethnicity , 2)
%     data_col = [data_col , temp_start , temp_start + 3 , temp_start + 6];
% end

% data_col = 5;
% for temp_start = 8 : 9 : size(ethnicity , 2)
%     data_col = [data_col , temp_start , temp_start + 3 , temp_start + 6];
% end

% data_col = [5 8 14 17 20];

% name_row = 3;

% Find columns with data
temp = ethnicity(: , 5);
name_row = find(cellfun(@(x) strcmp(x , '汉族') , temp , 'un' , 1));
name_row = name_row(1);
% disp(name_row);
temp_data_col = find(cellfun(@(x) ischar(x) , ethnicity(name_row , :) , 'un' , 1));
data_col = temp_data_col(cellfun(@(x) contains(x , '族') , ethnicity(name_row , temp_data_col) , 'un' , 1));

disp(ethnicity(name_row , data_col));

ethnicity_data = str2double(ethnicity(6 : end , data_col));
ethnicity_data(isnan(ethnicity_data)) = 0;

% City level or county level
if size(ethnicity , 1) < 40 || size(inter , 1) < 40
    keep = 1 : size(ethnicity_place , 1);
else
    keep = find(cellfun(@(x) strcmp(x(1) , ' ') , ethnicity_place));
end
    
ethnicity_place = ethnicity_place(keep);
ethnicity_data = ethnicity_data(keep , :);
ethnicity_place = cellfun(@(x) strtrim(x) , ethnicity_place , 'un' , 0);

%% clean up inter marriage data
inter_place = inter(6 : end , 1);
inter_place(cellfun(@(x) ~ischar(x) , inter_place , 'un' , 1)) = {'b'};

% Columns with ethnicities
inter_data = str2double(inter(6 : end , 4));

if size(inter , 1) < 40 || size(ethnicity , 1) < 40
    keep = 1 : size(inter_place , 1);
else
    keep = find(cellfun(@(x) strcmp(x(1) , ' ') , inter_place));
end

inter_place = inter_place(keep);
inter_data = inter_data(keep , :);
inter_place = cellfun(@(x) strtrim(x) , inter_place , 'un' , 0);

disp(inter_data');

%% Pool data
place = intersect(ethnicity_place , inter_place);
[~ , idx] = ismember(place , ethnicity_place);
ethnicity_data = ethnicity_data(idx , :);
[~ , idx] = ismember(place , inter_place);
inter_data = inter_data(idx);

% Predicted rate of inter-ethnicity marriage
ethnicity_data_fraction = ethnicity_data ./ repmat(sum(ethnicity_data , 2) , 1 , size(ethnicity_data , 2));
inter_predicted = 1 - sum(ethnicity_data_fraction .^ 2 , 2);
inter_normalized = (100 - inter_data) / 100 ./ inter_predicted;

disp(place');
disp(inter_normalized');

save(['MAT/' , filename , '.mat']);

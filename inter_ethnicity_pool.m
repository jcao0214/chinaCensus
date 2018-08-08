% Pool data for inter-ethnicity marriage map
%% Load data
clearvars;
load('cleanData.mat' , 'coors' , 'places');

china_provinces = shaperead('ChinaProvince/ChinaProvince.shp' , 'usegeocoords' , true);
china_provinces([5 32]) = [];

files = dir('MAT/*.mat');

inter_data = [];
inter_predicted = [];
inter_normalized = [];
place = [];
province = [];
scattersize = [];
defaultsize = 20;
biggersize = 40;

for n = 1 : numel(files)
    f = files(n);
    name = f.name(1 : end - 4);
    data = load([f.folder , filesep , f.name]);
    inter_data = [inter_data ; data.inter_data];
    inter_predicted = [inter_predicted ; data.inter_predicted];
    inter_normalized = [inter_normalized ; data.inter_normalized];
    place = [place ; data.place];
    province = [province ; repmat({name} , numel(data.place) , 1)];
    
    if numel(data.place) < 30
        scattersize = [scattersize ; repmat(biggersize , numel(data.place) , 1)];
    else
        scattersize = [scattersize ; repmat(defaultsize , numel(data.place) , 1)];
    end
    dispProgress(n , numel(files) , 1);
end

save('inter_ethnicity_pool.mat');

%% Plot figures
figurew;
subplot(121);
histogram(((100 - inter_data)));
set(gca , 'color' , [.98 .98 .98] , 'fontsize' , 16);
xlabel('Percentage of inter-ethnic families' , 'fontsize' , 18);

% subplot(132);
% histogram(log10(inter_predicted));
% set(gca , 'fontsize' , 16);
% xlabel('Predicted fraction of inter-ethnicity families' , 'fontsize' , 20);

subplot(122);
histogram(inter_normalized);
set(gca , 'color' , [.98 .98 .98] , 'fontsize' , 16);
xlabel('Normalized occurence of inter-ethnic families' , 'fontsize' , 18);

%% Plot map: normalized #
[found , idx] = ismember(place , places);

h = figurew;
set(gcf , 'color' , 'w' , 'position' , [    1           5        1366         668]);
ax = worldmap('China');
setm(ax , 'mapprojection' , 'miller' , 'MapLatLimit' , [14 57] , 'MapLonLimit' , [70 140] , 'frame' , 'off' , 'grid' , 'off');
% set(ax , 'position' , [-0.1 -0.05 1.2 1.15]);
delete(handlem('mlabel',ax));
delete(handlem('plabel',ax));
h_borders = geoshow(china_provinces , 'edgecolor' , [.2 .2 .2] , 'linewidth' , 0.5 , 'facecolor' , [.98 .98 .98]);

hold on;

scatterm_alpha(coors(idx(found) , 1) , coors(idx(found) , 2) , scattersize(found) , inter_normalized(found) , ...
        'filled' , 'markerfacealpha' , 1 , 'markeredgecolor' , [.5 .5 .5]);
title('\rmNormalized occurence of inter-ethnic families' , 'fontsize' , 24);

colormap(cbrewer('seq' , 'YlGnBu' , 40));
hc = colorbar;
set(gca , 'clim' , [0 1.5]);
set(hc , 'fontsize' , 16 , 'ytick' , 0 : 0.5 : 1.5);

%% Plot map: un-normalized #
h = figurew;
set(gcf , 'color' , 'w' , 'position' , [    1           5        1366         668]);
ax = worldmap('China');
setm(ax , 'mapprojection' , 'miller' , 'MapLatLimit' , [14 57] , 'MapLonLimit' , [70 140] , 'frame' , 'off' , 'grid' , 'off');
% set(ax , 'position' , [-0.1 -0.05 1.2 1.15]);
delete(handlem('mlabel',ax));
delete(handlem('plabel',ax));
h_borders = geoshow(china_provinces , 'edgecolor' , [.2 .2 .2] , 'linewidth' , 0.5 , 'facecolor' , [.98 .98 .98]);

hold on;

scatterm_alpha(coors(idx(found) , 1) , coors(idx(found) , 2) , scattersize(found) , 100 - inter_data(found) , ...
    'filled' , 'markerfacealpha' , 1 , 'markeredgecolor' , [.5 .5 .5]);
title('\rmPercentage of inter-ethnic families' , 'fontsize' , 24);

% colormap(summer(20));
colormap(cbrewer('seq' , 'YlGnBu' , 40));
hc = colorbar;
set(gca , 'clim' , [0 20]);
set(hc , 'fontsize' , 16 , 'ytick' , 0 : 5 : 20);

%% Plot scatter
figurew;
colors = cbrewer('qual' , 'Set1' , 5);
scattercolors = repmat(colors(2 , :) , numel(province) , 1);

xinjiang = cellfun(@(x) strcmp(x , 'xinjiang') , province , 'un' , 1);
xizang = cellfun(@(x) strcmp(x , 'xizang') , province , 'un' , 1);
yunnan = cellfun(@(x) strcmp(x , 'yunnan') , province , 'un' , 1);
neimeng = cellfun(@(x) strcmp(x , 'neimenggu') , province , 'un' , 1);
highlight = xinjiang | xizang | yunnan | neimeng;

scattercolors(xinjiang , :) = repmat(colors(1 , :) , sum(xinjiang) , 1);
scattercolors(xizang , :) = repmat(colors(3 , :) , sum(xizang) , 1);
scattercolors(yunnan , :) = repmat(colors(4 , :) , sum(yunnan) , 1);
scattercolors(neimeng , :) = repmat(colors(5 , :) , sum(neimeng) , 1);

scatter(inter_predicted(~highlight) , (100 - inter_data(~highlight)) / 100 , 20 , scattercolors(~highlight , :) , ...
    'filled' , 'markerfacealpha' , 0.2);
hold on;
scatter(inter_predicted(highlight) , (100 - inter_data(highlight)) / 100 , 20 , scattercolors(highlight , :) , ...
    'filled' , 'markerfacealpha' , 0.7);
set(gca , 'xscale' , 'log' , 'yscale' , 'log' , 'color' , [.95 .95 .95] , 'box' , 'on' , 'fontsize' , 16);
set(gca , 'xlim' , [1e-5 5]);
% axis equal;

xlabel('Frequency of inter-ethnic families by random change' , 'fontsize' , 18);
ylabel('Actual frequency' , 'fontsize' , 18);

text(2e-5 , 2e-1 , '\bfAll' , 'color' , colors(2 , :) , 'fontsize' , 18);
text(2e-5 , 2e-1 , '\bfXinjiang' , 'color' , colors(1 , :) , 'fontsize' , 18);
text(2e-5 , 2e-1 , '\bfTibet' , 'color' , colors(3 , :) , 'fontsize' , 18);
text(2e-5 , 2e-1 , '\bfYunnan' , 'color' , colors(4 , :) , 'fontsize' , 18);
text(2e-5 , 2e-1 , '\bfInner Mongolia' , 'color' , colors(5 , :) , 'fontsize' , 18);

set(gca , 'linewidth' , 1.5);


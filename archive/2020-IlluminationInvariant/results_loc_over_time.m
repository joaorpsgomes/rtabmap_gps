
close all
clear all

pkg load signal

# rtabmap-report --loc 32 Loop/Map_id/ loc
# Right-click on thr legend of the figure, copy all data to clipboard
# Paste in data#.txt where # is the number of the descriptor used

resultsToShow = 1; % 1=single loc, 2=merged loc, 3=consecutive
skipFrameDir = '0';

datasetPrefix = 'Stat';
datasets = [0 1 6 7 9 12 14 11]; % 0 1 6 7 8 9 11 12
datasetsName = {'SURF' 'SIFT' 'ORB' 'FAST/FREAK' 'FAST/BRIEF' 'GFTT/FREAK' 'GFTT/BRIEF' 'BRISK' 'GFTT/ORB' 'KAZE' 'ORB-OCTREE' 'SuperPoint' 'SURF/FREAK' 'GFTT/DAISY' 'SURF/DAISY'};
sep = [0, 1000, 3000, 5000, 7000, 9000, 12000];
sepName = {'16:51', '17:31', '17:58', '18:30', '18:59', '19:42'};

if resultsToShow == 3
  sep = [0, 1000, 3000, 5000, 7000, 9000];
  sepName = {'17:27', '17:54', '18:27', '18:56', '19:35'};
  datasetPrefix = 'Consecutive'
endif

percentResults = {};
totalResults = {};
locResults = {};

figure

colors = get(gca, 'ColorOrder');
tmp=colors(3,:);
colors(3,:) = colors(5,:);
colors(5,:) = tmp;

globalSeparators = [];
globalx = [];
globaly = [];
globalc = [];

for d=1:length(datasets)

data = dlmread([skipFrameDir '/' datasetPrefix  num2str(datasets(d)) '-Loop-Map_id-' '.txt'], '\t', 1, 0, "emptyvalue", NaN);

curvesBeg = 2;
curvesEnd = size(data,2)-4;

if resultsToShow == 2
  curvesBeg = 8;
  curvesEnd = size(data,2);
elseif resultsToShow == 3
  curvesEnd = size(data,2);
endif
curves = curvesEnd - curvesBeg + 1;

percentResultsTmp = zeros(curves, length(sep)-1);
totalResultsTmp = zeros(curves, length(sep)-1);
locResultsTmp = zeros(curves, length(sep)-1);

offset = 1;

for i = 1:curves
  index = i + curvesBeg - 1;
  separators = [];
  x_all = [];
  y_all = [];
  m_all = [];
  previousMax = 0;
  for j = 1:length(sep)-1
    x = data(:,1);
    y = data(:,index);
    y = y(x>=sep(j) & x<=sep(j+1), :);
    x = x(x>=sep(j) & x<=sep(j+1), :);
    minimum = x(1,1);
    separators = [separators previousMax];
    x = x - (minimum-previousMax);
    previousMax = x(end,1);
    y = y + 1;
    m = y;
    y(y>0) = 1;
    y(isnan(y)) = 0;
    percent = sum(y)/length(y);
    percentResultsTmp(i,j) = percent;
    locResultsTmp(i,j) = sum(y);
    totalResultsTmp(i,j) = length(y);
    y(y>0) =  -(d-1)*curves -i - (d-1)*offset;
    %x(y==0) = nan;
    m(y==0) = nan;
    y(y==0) = nan;
    if resultsToShow == 2
      if i==1 %% Merged 1, 6
        m(m==1) = 1;
        m(m==2) = 6;
      elseif i==2 %% Merged 1,3(2 sessions),5
        m(m==1) = 1;
        m(m==2) = 3;
        m(m==3) = 3;
        m(m==4) = 5;
      elseif i==3 %% Merged 2(2 sessions),4,6
        m(m==1) = 2;
        m(m==2) = 2;
        m(m==4) = 6;
        m(m==3) = 4;
      elseif i>=4 %% Merged 1, 2(2 sessions), 3(2 sessions),4,5,6
        m(m==1) = 1;
        m(m==2) = 2;
        m(m==3) = 2;
        m(m==4) = 3;
        m(m==5) = 3;
        m(m==6) = 4;
        m(m==7) = 5;
        m(m==8) = 6;
      endif
    endif
    x = upsample(x, 2);
    y = upsample(y, 2);
    m = upsample(m, 2);
    x(2:2:end-1) = x(3:2:end);
    y(2:2:end-1) = y(3:2:end);
    m(2:2:end) = m(1:2:end);
    x = x(1:end-1);
    y = y(1:end-1);
    m = m(1:end-1);
  
    x_all = [x_all nan x'];
    y_all = [y_all nan y'];
    m_all = [m_all nan m'];
  endfor
  if resultsToShow == 2
    globalx = [globalx x_all];
    globaly = [globaly y_all];
    globalc = [globalc m_all];
  else
    plot(x_all,y_all, 'linewidth', 3, 'color', colors(i,:))
    hold on
  endif
  separators = [separators previousMax];
  globalSeparators = separators;
endfor
percentResults{1,d} = percentResultsTmp;
totalResults{1,d} = totalResultsTmp;
locResults{1,d} = locResultsTmp;
endfor

if resultsToShow == 2
  indColors = ones(length(globalc), 3);
  for j=1:length(globalc)
    if ~isnan(globalc(j))
      indColors(j,:) = colors(globalc(j),:);
     endif
  endfor
  for i=1:6
    tmpx = globalx;
    tmpy = globaly;
    tmpx(globalc~=i) = nan;
    tmpy(globalc~=i) = nan;
    plot(tmpx, tmpy, 'linewidth', 3, 'color', colors(i,:));
    if i==1
      hold on
    endif
  endfor
endif

for j=1:length(globalSeparators)
  x = globalSeparators(j);
  plot([x,x],[(-length(datasets)*(curves+1)) ,0], 'k','linewidth', 2);
endfor

for d=1:length(datasets)
annotation ("textbox", [0, 0.96-((d-0.5)/length(datasets))*0.95, 0,0], 'string', datasetsName{datasets(d)+1})
endfor
for s=1:length(sep)-1
annotation ("textbox", [0.1 + ((separators(s+1)-separators(s))/2+separators(s))/separators(end)*0.75, 0.98, 0,0], 'string', sepName{s})
endfor
axis('tight')



set(gca, 'units', 'normalized');
Tight = get(gca, 'Position');
NewPos = [Tight(1) 0.01 0.77 0.95]; %New plot position [X Y W H]
set(gca, 'Position', NewPos);
if length(sep) == 7
  legend('16:46', '17:27', '17:54', '18:27', '18:56', '19:35', "location", 'northeastoutside' )
else
  legend('16:46', '17:27', '17:54', '18:27', '18:56', "location", 'northeastoutside' )
endif
box off
axis off

#disp(percentResults);
#disp(totalResults);

figure; 
for d=1:length(datasets)
  subplot(4,2,d)
  data=percentResults{1,d}*100;
  data(isnan(data)) = 0;
  hAxes = gca;
  imagesc( hAxes, data, [0, 100])
  %title({"",datasetsName{datasets(d)+1}})
  colors = [ones(100,1) [1:100]'*0.01 [1:100]'*0];
  colors(1,:) = 1;
  colormap( hAxes ,  colors)
  c = colorbar;
  labels = {};
  for v=get(c,'ytick'), labels{end+1} = sprintf('%d%%',v); end
  set(c,'yticklabel',labels);
  if mod(d,2) == 1
    ylabel("Map")
  endif
  xlabel([datasetsName{datasets(d)+1} " Localization"])
  set (gca, "xaxislocation", "top");
  set(gca, 'XTickLabel', sepName, 'fontsize',7)
  if resultsToShow == 3
    set(gca, 'YTickLabel', {'16:46', '17:27', '17:54', '18:27', '18:56'}, 'fontsize',7)
  elseif resultsToShow == 2
    set(gca, 'YTickLabel', {'1+6', '1+3+5', '2+4+6', '1+2+3+4+6', 'bundle', 'reduced'}, 'fontsize',7)
  else
    set(gca, 'YTickLabel', {'16:46', '17:27', '17:54', '18:27', '18:56', '19:35'}, 'fontsize',7)
  endif
endfor
    
% compute cumulative localizations
cumResults = zeros(curves+2, length(datasets)+1);
for d=1:length(datasets)
  cumResults(1,d+1) = datasets(d);
  cumResults(2:end-1,d+1) = round(sum(locResults{1,d}, 2) ./ sum(totalResults{1,d}, 2) * 100);
  if resultsToShow == 1
    cumResults(end,d+1) = round(sum(sum(locResults{1,d}.*eye(curves,curves))) / sum(totalResults{1,d},2)(1,1) * 100);
  endif
end
cumResults(2:end-1,1) = 1:curves;
cumResults
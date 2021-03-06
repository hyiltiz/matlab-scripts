function [hout, cols] = plotDendrogram(h, D)


 [X,   Y,    T,   color,   label,   horz, orientation,  Z] = deal(...
D.X, D.Y,  D.T, D.color, D.label, D.horz, D.orientation, D.Z);    

m = size(Z,1)+1;
threshold = 0.7 * max(Z(:,3));


if isempty(h) || all(h == 0)
    if  isempty(get(0,'CurrentFigure')) || ishold
        figure('Position', [50, 50, 800, 500]);
    else
        newplot;
    end
    h = zeros(m-1,1);
    parentAxes = gca;
else    
    if length(h) > m-1  % ie. dendrogram is smaller than last time
        set(h(m:end), 'visible', 'off') % hide the lines that we don't need
    elseif length(h) < m-1
        h(m-1) = 0;       % add space for extra handles        
    end
    parentAxes = get(h(1), 'parent');
end

% set up the color

theGroups = 1;
groups = 0;
cmap = [0 0 1];

if color
    groups = sum(Z(:,3)< threshold);
    if groups > 1 && groups < (m-1)
        theGroups = zeros(m-1,1);
        numColors = 0;
        for count = groups:-1:1
            if (theGroups(count) == 0)
                P = zeros(m-1,1);
                P(count) = 1;
                P = colorcluster(Z,P,Z(count,1),count);
                P = colorcluster(Z,P,Z(count,2),count);
                numColors = numColors + 1;
                theGroups(logical(P)) = numColors;
            end
        end 
        cmap = jet(numColors);
        cmap(end+1,:) = [0 0 0]; 
    else
        groups = 1;
    end
    
end  


col = zeros(m-1,3);

A = zeros(4,m-1);
B = A;

for n = 1:(m-1)
    i = Z(n,1); j = Z(n,2); w = Z(n,3);
    A(:,n) = [X(i) X(i) X(j) X(j)]';
    B(:,n) = [Y(i) w w Y(j)]';
    X(i) = (X(i)+X(j))/2; Y(i)  = w;
    if n <= groups
        col(n,:) = cmap(theGroups(n),:);
    else
        col(n,:) = cmap(end,:);
    end
end    
        
    
ymin = min(Z(:,3));
ymax = max(Z(:,3));
margin = (ymax - ymin) * 0.05;
n = size(label,1);


if(~horz)
    for count = 1:(m-1)
        if h(count) == 0
            h(count) = line(A(:,count),B(:,count),'color',col(count,:), 'parent', parentAxes);
        else
            set( h(count), 'xdata', A(:,count), 'ydata', B(:,count), 'color',col(count,:), 'visible', 'on');
        end
    end               
    
    lims = [0 m+1 max(0,ymin-margin) (ymax+margin)];
    set(parentAxes, 'Xlim', [.5 ,(n +.5)], 'XTick', 1:n, 'XTickLabel', label, ...
        'Box', 'off');
    mask = logical([0 0 1 1]); 
    if strcmp(orientation,'b')
        set(parentAxes,'XAxisLocation','top','Ydir','reverse');
    end 
else
    for count = 1:(m-1)
        if h(count) == 0
            h(count) = line(B(:,count),A(:,count),'color',col(count,:), 'parent', parentAxes);
        else
            set(h(count), 'xdata', B(:,count), 'ydata', A(:,count), 'color',col(count,:), 'visible', 'off');
        end
    end
        
    lims = [max(0,ymin-margin) (ymax+margin) 0 m+1 ];
    set(parentAxes, 'Ylim', [.5 ,(n +.5)], 'YTick', 1:n, 'YTickLabel', label, ...
        'Box', 'off');
    mask = logical([1 1 0 0]);
    if strcmp(orientation, 'l')
        set(parentAxes,'YAxisLocation','right','Xdir','reverse');
    end
end

if margin==0
    if ymax~=0
        lims(mask) = ymax * [0 1.25];
    else
        lims(mask) = [0 1];
    end
end
axis(parentAxes, lims);
if nargout>0
    hout = h;
end

if nargout>1
    cols = leafcolors(label, A', B', col);
end


% ---------------------------------------
function T = colorcluster(X, T, k, m)
% find local clustering

n = m; 
while n > 1
    n = n-1;
    if X(n,1) == k % node k is not a leave, it has subtrees
        T = colorcluster(X, T, k, n); % trace back left subtree
        T = colorcluster(X, T, X(n,2), n);
        break;
    end
end
T(m) = 1;


% ---------------------------------------
function cols = leafcolors(labels_str, xdata, ydata, Ucolors)
% find local clustering

N = size(labels_str,1);
xlabels_num = zeros(N, 1);
for i = 1:size(labels_str,1)
    xlabels_num(i) = str2double(labels_str(i,:));
end

% ydata = get(H, 'ydata'); ydata = cat(1, ydata{:});
% xdata = get(H, 'xdata'); xdata = cat(1, xdata{:});
[r,c] = find(ydata == 0);

cols    = zeros(N,3);
for i = 1:N
    h_idx = r(i);
    col = Ucolors(h_idx,:);
    x_coord = xdata(r(i), c(i));
    x_idx = xlabels_num(x_coord);
    cols(x_idx,:) = col;
end

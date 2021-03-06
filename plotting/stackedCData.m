function [cdata_idxs, X, colorbar_ticks] = stackedCData(X, x_lims)
    if nargin < 1
        nLayers = 4;
        imSize = [40, 50];
        X = zeros([imSize,nLayers]);
        bumpSize = 13;
        bump = fspecial('gaussian', bumpSize, 2);
        bump = bump/max(bump(:));
        padTot = imSize - bumpSize;
        for layer_i = 1:nLayers
            padT = randi(padTot(1)); padB = padTot(1)-padT;
            padL = randi(padTot(2)); padR = padTot(2)-padL;
            Xi = padarray2(bump, padL, padR, padT, padB);
            Xi = Xi*randi(10) + randi(10);
            X(:,:,layer_i) = Xi;
        end
    end

    nLayers = size(X,3);
    addBlackAtBottom = true;
    
    haveXlims = exist('x_lims', 'var') && ~isempty(x_lims);
    if haveXlims && isvector(x_lims)
        x_lims = repmat(x_lims(:), 1, nLayers);
    end
    
    nLevelsTot = 255;

    nLevelsEachColor = floor((nLevelsTot-addBlackAtBottom) / nLayers);        
    
    stacked_idxs = arrayfun(@(col_i) addBlackAtBottom + [1:nLevelsEachColor] + (col_i-1)*nLevelsEachColor, 1:nLayers, 'un', 0);
    colorbar_ticks = cell(1, nLayers);
    %%
    X_rescaled = zeros(size(X));
    for layer_i = 1:nLayers
        Xi = X(:,:,layer_i);
        L_abs = lims(Xi, 0);
        L = lims(Xi, .01);
        if haveXlims
            L = x_lims(:,layer_i);
        end
        
        Xi = (Xi - L(1)) / (L(2)-L(1)+eps);
        if diff(L_abs) == 0
            Xi(:) = 0;
        end
        Xi(Xi < 0) = 0;
        Xi(Xi > 1) = 1;
        assert(all(ibetween(Xi(:), 0, 1)))
        
        colorbar_ticks{layer_i} = linspace(0, 1, nLevelsEachColor)*(L(2)-L(1)) + L(1);
        
        Xi = round(Xi * nLevelsEachColor);
        Xi(Xi == 0) = 1;
        assert(all(ibetween(Xi(:), 1, nLevelsEachColor)))
        
        X_rescaled(:,:,layer_i) = Xi;
    end

    [~, layer_max_idxs] = max(X_rescaled, [], 3);
    
    
    cdata_idxs = zeros(size(X,1), size(X,2));
    for i = 1:size(X,1)
        for j = 1:size(X,2)
            l_idx = layer_max_idxs(i,j);
            cdata_idxs(i,j) = stacked_idxs{l_idx}(X_rescaled(i,j,l_idx));
        end
    end
    
    
end




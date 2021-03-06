function dZ = dgabor(A, mu_x, mu_y, sig_x, sig_y, theta, k, phi, C, XY, finiteDifference_Flag) 
    % gaborParameters is a vector of 9 parameters:  (A, mu_x, sig_x, mu_y, sig_y, k, phi, theta, const)
    % X can be:
        % - a single co-ordinate [x;y]
        % - a list of co-oordinates [x1, x2, ... xn; y1, y2, ... yn]
        %        (in columns or rows)
        % - a cell containing a matrix of x and y co-ordinates {X, Y}
    % providing a third parameter ('gradientFlag') makes the function return the
    %    gradient of the gabor function instead of just the gabor function.
    constAllowed = true;
    
    nParams = 8+constAllowed;
    
    doFiniteDiff = exist('finiteDifference_Flag', 'var') && ~isempty(finiteDifference_Flag);
    
    % X can be:
        % - a single co-ordinate [x;y]
        % - a list of co-oordinates [x1, x2, ... xn; y1, y2, ... yn]
        %        (in columns or rows)
    
    Xc = [mu_x; mu_y];
        	    
    % X can be a list of co-ordinates: with row (or column) is a set of co-ordiantes;
        
    [m,n] = size(XY);
    if (m == 2)
        % ok - keep X as is
    elseif (n == 2)
        XY = XY';
    else
        error('X is not the right shape: dimensions must be mx2 or 2xn');
    end
    
    % gabor gradient function;
    X = XY(1,:);
    Y = XY(2,:);

    XYp = shiftAndRotate(XY, Xc, theta);        
    Xp = XYp(1,:);
    Yp = XYp(2,:);        
%     Z = A .* expsqr(Xp, 0, sig_x) .* expsqr(Yp, 0, sig_y) .* cos( k * Xp + phi ) + C;        
        
    if ~doFiniteDiff
        exp_Xp = expsqr(Xp, sig_x);%  exp( -(Xp.^2)./(2*sig_x^2));
        exp_Yp = expsqr(Yp, sig_y);%  exp( -(Yp.^2)./(2*sig_y^2));
        cos_Xp = cos( k*Xp + phi );
        sin_Xp = sin( k*Xp + phi );
        ex_ey_cx = exp_Xp .* exp_Yp .* cos_Xp;
        ex_ey_sx = exp_Xp .* exp_Yp .* sin_Xp;

        dG_dxp = A * (ex_ey_cx .* (-Xp/(sig_x^2)) - ex_ey_sx * k);
        dG_dyp = A *  ex_ey_cx .* (-Yp/(sig_y^2)) ;

        dxp_dmu_x = -cos(theta);
        dyp_dmu_x =  sin(theta);        
        dxp_dmu_y = -sin(theta);
        dyp_dmu_y = -cos(theta);
        dxp_dtheta = -(X-mu_x)*sin(theta) + (Y-mu_y)*cos(theta);
        dyp_dtheta = -(X-mu_x)*cos(theta) - (Y-mu_y)*sin(theta);

        dG_dA     = ex_ey_cx;
        dG_dmu_x  = dG_dxp .* dxp_dmu_x + dG_dyp .* dyp_dmu_x;
        dG_dmu_y  = dG_dxp .* dxp_dmu_y + dG_dyp .* dyp_dmu_y;
        dG_dsig_x = A * ex_ey_cx .* (Xp.^2 / sig_x^3);
        dG_dsig_y = A * ex_ey_cx .* (Yp.^2 / sig_y^3);
        dG_dk     = A * ex_ey_sx .* (-Xp);
        dG_dphi   = A * ex_ey_sx * (-1);
        dG_dtheta = dG_dxp .* dxp_dtheta + dG_dyp .* dyp_dtheta;

        if constAllowed
            dG_dconst = ones(1, size(X,2));
        else
            dG_dconst = zeros(1, size(X,2), 0);
        end

        
        stackdim = 1;
        dZ = cat(stackdim, ... 
            dG_dA, dG_dmu_x, dG_dmu_y, dG_dsig_x, dG_dsig_y, dG_dtheta, dG_dk, dG_dphi, dG_dconst)';


        
    elseif doFiniteDiff
        
        delta = 1e-3;
        n = length(XY);
        dZ = zeros([n, nParams]);
        P = {A, mu_x, mu_y, sig_x, sig_y, theta, k, phi, C};
            
        for p_i = 1:nParams;
            pplus = P;   pplus{p_i}  = pplus{p_i}  + delta;
            pminus = P;  pminus{p_i} = pminus{p_i} - delta;
            dZ(:,p_i) = (gabor(pplus{:}, XY) - gabor(pminus{:}, XY) ) / (2*delta);
        
        end
        
    end
        
                
end

    

function y = expsqr(x, sigma)  
    y = exp( -(x.^2)./(2*sigma^2));
end

% function y = expsqr(x, mu, sigma)  
%     y = exp( -((x-mu).^2)./(2*sigma^2));
% end

function Xp = shiftAndRotate(X, Xc, theta)  
        Xp = bsxfun(@minus, X, Xc);
    Xp = rotationMatrix(-theta) * (Xp);
end
    
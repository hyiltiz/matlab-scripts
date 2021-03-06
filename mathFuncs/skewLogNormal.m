function y = skewLogNormal(f, f_opt, r_max, r_bkg, w, s)
    if any(f == 0)    
        f(f==0) = eps;
    end
    y = abs(r_max - r_bkg)./(1-exp(-1/s.^2)) * ( exp( - ( log(f./f_opt)./(w + s.*log(f./f_opt) ) ).^2 ) - exp(-1./s.^2) ) + r_bkg;
    if any(isnan(y))
        i_inff = isinf(f);        
        y(i_inff) = r_bkg;
    end

%     {
%         num1 = log(f./f_opt);
%         denom1 = (w + s.*log(f./f_opt));
%         exp1 = exp( - ( num1./denom1 ).^2 );
%         exp2 = exp(-1./s.^2);
%         prefactor = abs(r_max - r_bkg)./(1-exp(-1/s.^2));
%         y = prefactor * ( exp1 - exp2 ) + r_bkg;
%     }
    
    
end

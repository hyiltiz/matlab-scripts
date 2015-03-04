% function testStatFunctions

    % make random sequences
    T = 1000;
    n = 200;
    M = 30;
    A1 = randi(M, n, 1);
    A2 = randi(M, n, 1);

    disp('Testing linear correlation');
    
    tic; for i = 1:T,  [cc1, cc_pval1] = corr(A1, A2);      end; t1 = toc;
    tic; for i = 1:T,  [cc2, cc_pval2] = pearsonR(A1, A2);  end; t2 = toc;
    tic; for i = 1:T,  cc3 = crossCorrelation(A1, A2);      end; t3 = toc;
    if T > 1
        fprintf('Built in: %g,  C: %g.  Mine: %g \n\n', t1, t2, t3 );
    end
        
    disp('Testing spearman''s rho ');
    tic; for i = 1:T,  [rho1, rho_pval1] = corr(A1, A2, 'type', 'spearman'); end; t1 = toc;
    tic; for i = 1:T,  [rho2, rho_pval2] = spearmanRho(A1, A2);              end; t2 = toc;    
    if T > 1        
        fprintf('Built in: %g, C: %g. \n\n', t1, t2);
    end
    
    disp('Testing kendall tau ');
    tic; for i = 1:T,  [tau1, tau_pval1] = corr(A1, A2, 'type', 'kendall'); end; t1 = toc;
    tic; for i = 1:T,  [tau2, tau_pval2] = kendallTau(A1, A2);              end; t2 = toc;    
    if T > 1        
        fprintf('Built in: %g,  C: %g. \n\n', t1, t2);
    end
    
    
    %     [d1, zd1, probd1, rs1, probrs1] = spearmanRhoM(A1, A2);

    % c code

% end
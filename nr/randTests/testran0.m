% n = 50000;
% a = zeros(1,n);
% seed = -50;
% ran0(seed);
% tic
% for i = 1:n
%     a(i) = ran0;
% end
% toc;
% hist(a, 50);
%     

n = 10;
seed = -137;
a = ran0(seed);
disp(['0) ' num2str(a)]);
for i = 1:n
    r = ran0;
    disp([num2str(i) ') ' num2str(r)]);    
end
    


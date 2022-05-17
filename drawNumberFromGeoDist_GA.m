function x = drawNumberFromGeoDist_GA(lowest, highest, steps, p)
%function x = drawNumberFromGeoDist_GA(lowest, highest, steps, p)
%%Draws an number from a truncated geometric distribution with 
%%event-probability p. The number will be between lowest and highest in
%%steps indicated by the "steps"
%
% last change: giacomo ariani 2015.01.22 (adapted from jens.schwarzbach@unitn.it)
%
%%Examples
%%1. Draw one random number between 0 and 8 in steps of 1, p of event = 0.4
%x = drawNumberFromGeoDist_GA(0, 8, 1, 0.4)
%
%%2. Draw 100000 random numbers between 0 and 10 in steps of 0.5, p of event = 0.2
%%   and plot frequency distribution
% n = 100000;
% y = zeros(n, 1);
% for i = 1:n
%    y(i) = drawNumberFromGeoDist_GA(0, 10, 0.5, 0.2);
% end
% mean(y)
% uy = unique(y);
% figure
% hist(y, numel(uy))
% xlabel('X')
% ylabel('frequency')

%define the range of possible outcomes
range=lowest:steps:highest;

%compute a probability density function for a truncated geometric
%distribution
pdel = zeros(1,length(range)); 
for i = 0:length(range)-1
    pdel(i+1)=p*(1-p)^i;
end

%since this is a truncated probability density function, the area under the
%curve is less than one. This is remedied by:
pdel = pdel/sum(pdel);

%compute the cumulative density function
cump = cumsum(pdel);

%pick a random number between 0 and 1
randnum = rand;

%in which class does the random number fall
[~, idx] = find(randnum <= cump);
x = range(min(idx));
%% Create TRD for N-subjects: yes-right
nSubjects = 30;
TRD = [];
for iSub=1:nSubjects
    if mod(iSub, 2)
        [TRD_, ~] = fillTRD_v2(iSub, [0,1], 1);
    else
        [TRD_, ~] = fillTRD_v2(iSub, [1,0], 1);
    end
    TRD = [TRD, TRD_];
end

%% Extract codes & count
%TRD = TRD_right;

codes = [TRD.code];
codes = codes(codes < 999);

info = getDesignParams();

%% Get unique codes from the simulation & decode
[C,ia,ic] = unique(codes);
a_counts = accumarray(ic,1);
value_counts = [C' a_counts];

%facLevels = {};
for i=1:length(a_counts)
    %disp([C(i), a_counts(i)])

    % Decode factors from code
    factors = ASF_decode(C(i), info.factorialStructure);
    c = factors(1);   % congruence
    d = factors(2);   % duration
    p = factors(3);   % probe
    r = factors(4);   % correct response
    % probe type
    if p > 8
        t = 0;
    else
        t = 1;
    end
    
    facLevels(i).Congruence = info.CongruenceLevels(c+1);
    facLevels(i).PT = info.PresTimeLevels(d+1);% * 1/60 * 1000;
    facLevels(i).ProbeType = info.ProbeTypeLevels(t+1);
    facLevels(i).Probe = info.ProbeLevels(p+1);
    facLevels(i).CorrectResponse = info.CorrectResponses(r+1);
    facLevels(i).count = a_counts(i);
end

%% Collect all possible outcomes & squeeze counts in there
% Because there might be missing codes in the simulation, get a
% full-structured overview of the distribution, including missing codes (if
% any).
i = 1;
for iCongruence = 1:info.nCongruenceLevels
    for iProbe = 1:info.nProbeLevels
        for iPresTime = 1:info.nPresTimeLevels
            for iResponse = 1:info.nCorrectResponses
                % probe type
                if iProbe > 9
                    iProbeType = 1;
                else
                    iProbeType = 2;
                end

                test = facLevels(...
                    [facLevels.Congruence] == info.CongruenceLevels(iCongruence) &...
                    [facLevels.ProbeType] == info.ProbeTypeLevels(iProbeType) & ...
                    [facLevels.Probe] == info.ProbeLevels(iProbe) & ...
                    [facLevels.PT] == info.PresTimeLevels(iPresTime) & ...
                    [facLevels.CorrectResponse] == info.CorrectResponses(iResponse));
                
                countsAll(i).Congruence = info.CongruenceLevels(iCongruence);
                countsAll(i).PT = info.PresTimeLevels(iPresTime);
                countsAll(i).ProbeType = info.ProbeTypeLevels(iProbeType);
                countsAll(i).Probe = info.ProbeLevels(iProbe);
                countsAll(i).CorrectResponse = info.CorrectResponses(iResponse);
                
                if isempty(test)
                    countsAll(i).count = 0;
                else
                    countsAll(i).count = test.count;
                end

                i = i + 1;
            end
        end
    end
end

%% PLOT main factor balancing
label_main = [];
counts_main_yes = [];
counts_main_no = [];
for iCongruence = 1:info.nCongruenceLevels
    for iProbeType = 1:info.nProbeTypeLevels
        for iPresTime = 1:info.nPresTimeLevels
            label_main = [label_main,...
                sprintf("%s : %s : %.1f", ...
                    info.CongruenceLevels(iCongruence), ...
                    info.ProbeTypeLevels(iProbeType), ...
                    info.PresTimeLevels(iPresTime) * 1/60 * 1000)];
            counts_y = [countsAll(...
                [countsAll.Congruence] == info.CongruenceLevels(iCongruence) &...
                [countsAll.ProbeType] == info.ProbeTypeLevels(iProbeType) &...
                [countsAll.PT] == info.PresTimeLevels(iPresTime) &...
                [countsAll.CorrectResponse] == 'yes').count];

            counts_n = [countsAll(...
                [countsAll.Congruence] == info.CongruenceLevels(iCongruence) &...
                [countsAll.ProbeType] == info.ProbeTypeLevels(iProbeType) &...
                [countsAll.PT] == info.PresTimeLevels(iPresTime) &...
                [countsAll.CorrectResponse] == 'no').count];
            counts_main_yes = [counts_main_yes, sum(counts_y)];
            counts_main_no = [counts_main_no, sum(counts_n)];
        end
    end
end


figure
bar([counts_main_yes; counts_main_no]')
hold on
xticks(1:length(label_main))
xticklabels(label_main)
xtickangle(70)

lgd = legend('YES','NO');
lgd.Location = 'best';
lgd.Title.String = 'Correct Response';
title('Main factors')
hold off

%% Compatible: YES vs NO
s_yes_comp = [countsAll([countsAll.Congruence] == 'compatible' &...
                             [countsAll.CorrectResponse] == 'yes')];
s_no_comp = [countsAll([countsAll.Congruence] == 'compatible' &...
                             [countsAll.CorrectResponse] == 'no')];
counts_yes_comp = [s_yes_comp.count];
counts_no_comp = [s_no_comp.count];

labels = [];
for i=1:length(s_yes_comp)
    labels = [labels, sprintf("%s : %s : %.1f", s_yes_comp(i).ProbeType, ...
                             s_yes_comp(i).Probe, s_yes_comp(i).PT * 1/60 * 1000)];
end

figure
bar([counts_yes_comp; counts_no_comp]')
hold on
xticks(1:length(labels))
xticklabels(labels)
xtickangle(70)

lgd = legend('YES','NO');
lgd.Location = 'best';
lgd.Title.String = 'Correct Response';

title('Compatible trials')

hold off

%% Incompatible: YES vs NO
s_yes_comp = [countsAll([countsAll.Congruence] == 'incompatible' &...
                             [countsAll.CorrectResponse] == 'yes')];
s_no_comp = [countsAll([countsAll.Congruence] == 'incompatible' &...
                             [countsAll.CorrectResponse] == 'no')];
counts_yes_comp = [s_yes_comp.count];
counts_no_comp = [s_no_comp.count];

figure
labels = [];
for i=1:length(s_yes_comp)
    labels = [labels, sprintf("%s : %s : %.1f", s_yes_comp(i).ProbeType, ...
                             s_yes_comp(i).Probe, s_yes_comp(i).PT * 1/60 * 1000)];
end

bar([counts_yes_comp; counts_no_comp]')
hold on
xticks(1:length(labels))
xticklabels(labels)
xtickangle(70)

lgd = legend('YES','NO');
lgd.Location = 'best';
lgd.Title.String = 'Correct Response';

title('Incompatible trials')

hold off

%% Incompatible: per context: YES vs NO
s_yes_comp = [countsAll([countsAll.Congruence] == 'incompatible' &...
                             [countsAll.CorrectResponse] == 'yes')];
s_no_comp = [countsAll([countsAll.Congruence] == 'incompatible' &...
                             [countsAll.CorrectResponse] == 'no')];
counts_yes_comp = [s_yes_comp.count];
counts_no_comp = [s_no_comp.count];

% Sum action probes within their source context
counts_yes_comp = [sum(counts_yes_comp(1:6*3)), ...         % action
                   sum(counts_yes_comp(6*3+1:2*6*3)),...    % action
                   sum(counts_yes_comp(2*6*3+1:3*6*3)),...  % action
                   sum(counts_yes_comp(3*6*3+1:3*6*3+6)),...
                   sum(counts_yes_comp(3*6*3+6+1:3*6*3+6*2)),...
                   sum(counts_yes_comp(3*6*3+6*2+1:3*6*3+6*3))];
counts_no_comp = [sum(counts_no_comp(1:6*3)), ...
                  sum(counts_no_comp(6*3+1:2*6*3)),...
                  sum(counts_no_comp(2*6*3+1:3*6*3)),...
                  sum(counts_no_comp(3*6*3+1:3*6*3+6)),...
                  sum(counts_no_comp(3*6*3+6+1:3*6*3+6*2)),...
                  sum(counts_no_comp(3*6*3+6*2+1:3*6*3+6*3))];
figure
labels = [];
for i=1:6
    if i < 4
        probe = "action";
        context = info.ContextLevels(i);
    else
        probe = "context";
        context = info.ContextLevels(i-3);
    end
    labels = [labels, sprintf("%s : %s", probe, context)];
end

bar([counts_yes_comp; counts_no_comp]')
hold on
xticks(1:length(labels))
xticklabels(labels)
xtickangle(70)

lgd = legend('YES','NO');
lgd.Location = 'best';
lgd.Title.String = 'Correct Response';

title('Within context (Incompatible)')

hold off

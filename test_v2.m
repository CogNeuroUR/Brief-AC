%% Create TRD for 10 subjects: yes-right
%[TRD_right, info] = fillTRD_v2(0, 20, 432, [0,1], 0);
[TRD, info] = fillTRD_v2(0, 1, 20, [0,1], 0);

%% Extract codes & count
%TRD = TRD_right;

codes = [TRD.code];
codes = codes(codes < 999);

info = getFactorialStructure();

%% Get unique codes
[C,ia,ic] = unique(codes);
a_counts = accumarray(ic,1);
value_counts = [C' a_counts];

%facLevels = {};
for i=1:length(a_counts)
    disp([C(i), a_counts(i)])

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


%% PLOT?
countsYESall = [];
countsNOall = [];

for iProbeType=1:info.nProbeTypeLevels
    counts_yes = [countsAll([countsAll.Congruence] == 'compatible' &...
                         [countsAll.CorrectResponse] == 'yes' & ...
                         [countsAll(i).ProbeType] == info.ProbeTypeLevels(iProbeType)).count];
    counts_no = [countsAll([countsAll.Congruence] == 'compatible' &...
                         [countsAll.CorrectResponse] == 'no' & ...
                         [countsAll(i).ProbeType] == info.ProbeTypeLevels(iProbeType)).count];
    disp(iProbeType)
    countsYESall = [countsYESall; counts_yes];
end

counts_yes_comp = [countsAll([countsAll.Congruence] == 'compatible' &...
                             [countsAll.CorrectResponse] == 'yes').count];
counts_no_comp = [countsAll([countsAll.Congruence] == 'compatible' &...
                             [countsAll.CorrectResponse] == 'no').count];
%bar([facLevels([facLevels.Congruence] == 'compatible').count])
%bar([counts_yes_comp; counts_no_comp]')

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

function [output] = runDataMainSequence(input)
%go through each session, load up the task files, pull the saccades and add
%them to a variable table by amplitude size. Then plot the main sequence

%load files
for sess = 1:length(sessions)
    %pull all the saccade data
    sacData = structfun(@(x) x.SaccadeData,taskStruct.Trials,'uni',0);
%     %if you have more tasks to compare
%     sacData = [sacData;structfun(@(x) x.SaccadeData,taskStruct2.Trials,'uni',0);
    
saccadeData.(sessions{sess}).MainSequence = KM_MainSequencePlotSmooth(sacData,taskStruct,taskStruct2);

end
% now that all session data is collected, get the means and IQR and then
% plot it
velCells = struct2cell(structfun(@(x) x.MainSequence.KM,saccadeData,'uni',0));
outVel = cell(1,10);
for ii = 1:length(velCells)
    for bin = 1:10
    outVel{bin} = [outVel{bin};velCells{ii}{bin}];
    end
end
binAmps = 2:3:29;
velVals = cellfun(@mean, outVel);
velErr = cellfun(@iqr,outVel);

% velCells2 = struct2cell(structfun(@(x) x.MainSequence.Comp,saccadeData,'uni',0));
% outVel2 = cell(1,10);
% for ii = 1:length(velCells2)
%     for bin = 1:10
%     outVel2{bin} = [outVel{bin};velCells2{ii}{bin}];
%     end
% end
% binAmps = 2:3:29;
% velVals2 = cellfun(@mean, outVel2);
% velErr2 = cellfun(@iqr,outVel2);

figure

errorbar([binAmps(~isnan(velVals))+1.5],velVals,...
    velErr(~isnan(velVals)),'LineWidth',5);
% errorbar([binAmps(~isnan(velVals2))+1.5],velVals2,...
%     velErr2(~isnan(velVals2)),'LineWidth',5);

% i used anova_rm from matlab central to analyze the means directly rather
% than the raw data




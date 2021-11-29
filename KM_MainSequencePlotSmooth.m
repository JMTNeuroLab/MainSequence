%function to get saccades from each trial type, and then pair off so that
%Main sequence can be calculated on a similar population
function [MainSequence] = KM_MainSequencePlotSmooth(SaccadeData,taskStruct,taskStruct2)
%% make sure to use only valid trials with all sections


SelectionOptions.Save            = 0;
SelectionOptions.SelectTrials    = 1;
SelectionOptions.RemoveTimeOuts  = 1;
SelectionOptions.TrialConditions = 0;
SelectionOptions.TrialCriteria = {'OutcomeCorr', {'Correct', 'Incorrect'}};

XMazeSelectTrials = HcTask_SelectTrials(taskStruct, SelectionOptions);
names = fieldnames(taskStruct.Trials);
taskStruct.Trials = rmfield(taskStruct.Trials,names(~ismember(names,XMazeSelectTrials.Trials)));

% %if you have a second struct to compare
% SelectionOptions.Save            = 0;
% SelectionOptions.SelectTrials    = 1;
% SelectionOptions.RemoveTimeOuts  = 1;
% SelectionOptions.TrialConditions = 0;
% SelectionOptions.TrialCriteria = {'OutcomeCorr', {'Correct', 'Incorrect'}};
% 
% XMazeSelectTrials = HcTask_SelectTrials(taskStruct2, SelectionOptions);
% names = fieldnames(taskStruct2.Trials);
% taskStruct2.Trials = rmfield(taskStruct2.Trials,names(~ismember(names,XMazeSelectTrials.Trials)));
% 




%% XMazeSaccades
trialNames = fieldnames(taskStruct.Trials);
for trl = 1:length(trialNames)
    XMazeSaccades(trl) = structfun(@(x) x,...
        SaccadeData.(trialNames{trl}),'uni',0);
end
names = fieldnames(XMazeSaccades);
cellData = cellfun(@(f) {vertcat(XMazeSaccades.(f))},names);
XMazeSaccades = cell2struct(cellData,names);

% %% Comparator task
% trialNames = fieldnames(taskStruct2.Trials);
% for trl = 1:length(trialNames)
%     XMazeSaccades(trl) = structfun(@(x) x,...
%         SaccadeData.(trialNames{trl}),'uni',0);
% end
% names = fieldnames(XMazeSaccades);
% cellData = cellfun(@(f) {vertcat(XMazeSaccades.(f))},names);
% CompSaccades = cell2struct(cellData,names);


%% Bin the saccades by amplitude, and then calculate quads that are matched for position

for bin = 2:3:29
    
    
    XMazeIndicies = find([XMazeSaccades.Amplitude]>(bin)...
        & [XMazeSaccades.Amplitude]<=bin+3);
%     CompIndicies = find([CompSaccades.Amplitude]>(bin)...
%         & [CompSaccades.Amplitude]<=bin+3);

    [Indicies2Analyze,skipped] = PairedOff4InputHorizontal(structfun(@(x) ...
        x(CompIndicies),CompSaccades,'uni',0),...
        structfun(@(x) x(XMazeIndicies),XMazeSaccades,'uni',0),[]);
  
    if~isempty(Indicies2Analyze)
        compBins{bin} = CompSaccades.PeakVelocity(Indicies2Analyze(:,1));
        binnedData{bin} = XMazeSaccades.PeakVelocity(Indicies2Analyze(:,2));
    elseif ~isempty(XMazeIndicies)
        binnedData{bin} =  XMazeSaccades.PeakVelocity(XMazeIndicies);
    end
end

%% Assign all of the used saccades to their respective bins

MainSequence.KM = binnedData(2:3:end);
% MainSequence.Comp = compBins{2:3:end);


function [PairedSaccadeIndices,skipped] = PairedOff4InputHorizontal(Least,Comparator1,Comparator2,Comparator3)
% takes in a set of saccades and pairs them off for analysis in a main
% sequence comparison, can take up to 4 inputs.
% similarity is done based on starting location of the saccade and
% direction of the saccade (calculated as the vector between the start and
% the end of the saccade



%   static = SacStruct.CorridorDescrip;dynamic = SacStruct.DecisionDescrip;
%

% static = SacStruct.StaticDescrip;
% dynamic = SacStruct.DynamicDescrip;
output = NaN(size(Least.StartTime,1),4);
skipped = NaN(size(Least.StartTime,1),1);
%take the input of static and dynamic saccades bins, and go through each of the
%static saccades, and find a close dynamic saccade, remove both from the
%potential pool, and add to the 'Analyse' pool
Comp1 = struct2table(Comparator1);
if ~isempty(Comparator2)
    Comp2 = struct2table(Comparator2);
end
if ~isempty(Comparator3)
    Comp3 = struct2table(Comparator3);
end
for sac = 1:size(Least.StartTime,1)
    % Remove the saccades that are too far away by degrees
    % take the value that is lowest using mod ( a-b) and mod(b-a)
    C1Rows = min(abs(mod((Least.Direction(sac)+180 )-  (Comp1.Direction+180),360)),...
        abs(mod((Comp1.Direction+180 )-  (Least.Direction(sac)+180),360)))<10;
    
    
    %calculate the hypotenuse of all the saccades start points and the archetype
    %saccade, and add it to the hypotenuse of the end points. find the
    %saccade with the minimum difference
    [val,pairIndex] = min(sqrt((Comp1.StartPointX(C1Rows)' - Least.StartPointX(sac)).^2 +...
        (Comp1.StartPointY(C1Rows)'-Least.StartPointY(sac)).^2));
    %get the indices that were viable pairs, and then pairIndex will be
    %updated to the index in the correct row
    C1Indices = find(C1Rows);
    pairIndex = C1Indices(pairIndex);
    
    
    % do the same with Comparator2
    if ~isempty(Comparator2)
        C2Rows = min(abs(mod((Least.Direction(sac)+180 )-  (Comp2.Direction+180),360)),...
            abs(mod((Comp2.Direction+180 )-  (Least.Direction(sac)+180),360)))<10;
        
        [val2,pairIndex2] = min(sqrt((Comp2.StartPointX(C2Rows)' - Least.StartPointX(sac)).^2 +...
            (Comp2.StartPointY(C2Rows)'-Least.StartPointY(sac)).^2));
        %get the indices that were viable pairs, and then pairIndex will be
        %updated to the index in the correct row
        C2Indices = find(C2Rows);
        pairIndex2 = C2Indices(pairIndex2);
        %If there is data for Comparator3, then calculate it
        
        if ~isempty(Comparator3)
            C3Rows = min(abs(mod((Least.Direction(sac)+180 )-  (Comp3.Direction+180),360)),...
                abs(mod((Comp3.Direction+180 )-  (Least.Direction(sac)+180),360)))<10;
            
            [val3,pairIndex3] = min(sqrt((Comp3.StartPointX(C3Rows)' - Least.StartPointX(sac)).^2 +...
                (Comp3.StartPointY(C3Rows)'-Least.StartPointY(sac)).^2));
            C3Indices = find(C3Rows);
            pairIndex3 = C3Indices(pairIndex3);
            %if there isn't a pair, skip this static saccade
            if isempty(pairIndex)|| val>=5 ||isempty(pairIndex2)|| val2>=5 ||isempty(pairIndex3)|| val3>=5
                skipped(sac) = sac;
                continue
            else
                %add both indices to the output variable
                output(sac,1:4) = [sac pairIndex pairIndex2 pairIndex3];
                %remove the paired off dynamic saccade
                Comp1.StartPointX(pairIndex) = [99999];
                Comp2.StartPointX(pairIndex2) = [99999];
                Comp3.StartPointX(pairIndex3) = [99999];
                %coninue on with the next saccade
            end
            
        else %Just process as two comparators
            if isempty(pairIndex)|| val>=5 ||isempty(pairIndex2)|| val2>=5
                skipped(sac) = sac;
                continue
            else
                %add both indices to the output variable
                output(sac,1:3) = [sac pairIndex pairIndex2 ];
                %remove the paired off dynamic saccade
                Comp1.StartPointX(pairIndex) = [99999];
                Comp2.StartPointX(pairIndex2) = [99999];
            end
        end
    else %if there are only two comparators, process as such
        if isempty(pairIndex)|| val>=5
            skipped(sac) = sac;
            continue
        else
            %add both indices to the output variable
            output(sac,1:2) = [sac pairIndex ];
            %remove the paired off dynamic saccade
            Comp1.StartPointX(pairIndex) = [99999];
        end
        
    end
end
output(isnan(output(:,1)),:)=[];
skipped(isnan(skipped))=[];
%if there wasn't a 3rd comparator, remove the final column of output
if isempty(Comparator3)
    output(:,4) = [];
    %if there was only one comparator, also remove the 3rd column
    if isempty(Comparator2)
        output(:,3) = [];
    end
end
PairedSaccadeIndices = output;

end

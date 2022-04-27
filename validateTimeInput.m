function warn = validateTimeInput(value)
    % validateTimeInput validates text input from text edit fields
    % params:
    %   - value: text input value
    
    warn = false;
    %Check if the text contains a ":" separator
    if(~contains(value,":"))
        warn = true;
    else
        split_value = split(value,':');
        %Check if there is only 1 ':'
        if(size(split_value,1) ~= 2)
            warn = true;
        else
            %Check if the hour string is longer
            if((size(split_value{1},2) > 2))
                warn = true;
            end    
            %Check if the minute string is not 2 characters long
            if((size(split_value{2},2) ~= 2))
                warn = true;
            end

            hour = str2num(split_value{1});
            min = str2num(split_value{2});

            %Check if the values are numbers
            if(isempty(hour) || isempty(min))
                warn = true; 
            end
            %Check if numbers are in range
            if(hour<0 || hour>23 || min<0 || hour>59)
                warn = true;                       
            end    
        end
    end
end
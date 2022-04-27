function string = convertMinToTime(minutesIn)
    if(minutesIn < 1440)
        mins = mod(minutesIn,60);
        hours = (minutesIn - mins) / 60;
        string = num2str(hours) + ":" + num2str(mins);    
    else
        error("Too many minutes")
    end
end
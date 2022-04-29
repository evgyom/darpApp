function string = convertMinToTime(minutesIn)
    if(minutesIn < 1440)
        mins = mod(minutesIn,60);
        hours = (minutesIn - mins) / 60;
        if(mins == 0)
            string = num2str(hours) + ":00";
        else
            string = num2str(hours) + ":" + num2str(mins);
        end
    else
        error("Too many minutes")
    end
end
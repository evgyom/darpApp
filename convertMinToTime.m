function string = convertMinToTime(minutesIn)
    if(minutesIn < 1440)
        mins = mod(minutesIn,60);
        hours = (minutesIn - mins) / 60;
        if(mins == 0)
            string = num2str(hours) + ":00";
        elseif(mins<10)
            string = num2str(hours) + ":0" + num2str(mins);
        else
            string = num2str(hours) + ":" + num2str(mins);
        end
    else
        error("Too many minutes")
    end
end
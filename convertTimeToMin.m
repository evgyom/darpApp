function time = convertTimeToMin(timeStringIn)
    split_value = split(timeStringIn,':');
    hour = str2num(split_value{1});
    min = str2num(split_value{2});
    time = 60*hour + min;
end
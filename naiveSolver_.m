initVehiclesPos();
filterImpossibleRequests();
[time, maxTime] = getTimeBounds();

while(time < maxTime)
    activeRequests = getActiveRequests();
    for request = activeRequests
        scheduleRequest(request)
    end
    allVehiclesStep();
    time = time + 1;
end

function requests = getActiveRequests()
    requests = 0;
    for request = possibleRequests
        if(~request.scheduled && request.pickupTime < time && request.dropoffTime>time)
            requests.append(request)
        end
    end
end

function scheduleRequest(request)
    distances = 0; 
    modes = 0;
    for vehicle = allVehicles
        [minDistance, mode] = getMinDistance(vehicle, request);       
    end
end

function [minDistance, mode] = getMinDistance(vehicle, request)
    a: p és d -> dist = 0
    b: csak P -> dist = dropOff - utolsóPont
    c: semelyik -> dist = 
end
classdef naiveSolver
    properties
        graph;
        allRequests;
        possibleRequests;
        vehicles;
        edgeTime;
        unservedRequests;
        startTime;
        maxTime;
        time;
    end
    
    methods
        %constructor
        function obj = naiveSolver(graphIn, requestsIn, vehiclesIn, edgeTimeIn)
            obj.graph = graphIn;
            obj.allRequests = requestsIn;
            obj.vehicles = vehiclesIn;
            obj.edgeTime = edgeTimeIn;
            obj.unservedRequests = [];
            
            obj.startTime = 0;
            obj.maxTime = 0; 
        end
        
        function obj = solve(obj)
            % Init things
            obj = obj.initTimeBounds();
            obj = obj.selectPossibleRequests();
            obj = obj.initVehiclesPos();
            
            obj.time = obj.startTime;
            % Iterate over all the time steps
            while(obj.time<=obj.maxTime)
                disp(obj.time)
                [numRequests, activeRequests] = obj.getActiveRequests();
                for i = 1:numRequests
                    [obj,activeRequests{i}]  = obj.scheduleRequest(activeRequests{i});
                end
                obj = obj.allVehiclesStep();
                obj.time = obj.time+1;
            end
        end
        
        function routes = getRoutes(obj)
            routes = cell(size(obj.vehicles,1),3);
            for i = 1:size(obj.vehicles,1)
                routes{i,1} = obj.vehicles(i).completeRoute;
                routes{i,1} = obj.vehicles(i).nodeServedTime;
                routes{i,1} = obj.vehicles(i).requestsServed;
            end
        end
    end
    
    methods (Access = private)
        
        function obj = initTimeBounds(obj)
            % Get the time bounds of the solution
            minStartTime = 60*24+999;
            maxEndTime = -1;
            for i = 1:size(obj.allRequests,1)
                if(obj.allRequests(i).pickUpTimeEarliest < minStartTime)
                    minStartTime = obj.allRequests(i).pickUpTimeEarliest;
                end
                
                if(obj.allRequests(i).dropOffTimeLatest > maxEndTime)
                    maxEndTime = obj.allRequests(i).dropOffTimeLatest;
                end
            end
            obj.startTime = minStartTime;
            obj.maxTime = maxEndTime;
        end
       
        function obj = selectPossibleRequests(obj)
            obj.possibleRequests = cell(1);
            % Filter out impossible requests
            for i = 1:size(obj.allRequests,1)
                % Get request properties
                pickUpNode = obj.allRequests(i).pickUpNodeId;
                dropOffNode = obj.allRequests(i).dropOffNodeId;
                distance = obj.graph.getDistance(pickUpNode,dropOffNode);
                timeWindow = obj.allRequests(i).dropOffTimeLatest - obj.allRequests(i).pickUpTimeEarliest;
                if(distance * obj.edgeTime <= timeWindow)
                    obj.possibleRequests{end+1,1} = obj.allRequests(i);
                end
            end
            obj.possibleRequests(1,:) = [];
        end
            
        function obj = initVehiclesPos(obj)
            % Init vehicle position
            for i = 1:size(obj.vehicles,1)
                obj.vehicles(i) = obj.vehicles(i).clearSolutionData();
                obj.vehicles(i).pos = obj.vehicles(i).depotNodeId;
            end
        end
        
        function [numRequests, activeRequests] = getActiveRequests(obj)
            %Return the active requests
            activeRequests = cell(1);
            numRequests = 0;
            for i = 1:size(obj.possibleRequests,1)
                if(obj.possibleRequests{i}.pickUpTimeEarliest <= obj.time && ...
                        obj.possibleRequests{i}.dropOffTimeLatest >= obj.time && ...
                        ~obj.possibleRequests{i}.served)
                    numRequests = numRequests + 1;
                    activeRequests{end+1,1} = obj.possibleRequests(i);
                end
            end
            % Delete the first row. Matlab magic.
            activeRequests(1,:) = [];
        end
        
        function [obj, requestOut] = scheduleRequest(obj, requestIn)
            requestIn = requestIn{1};
            minAddTime = -1;
            minMode = -1;
            bestVehicle = 0;
            bestVehicleIndex = 0;
            for i = 1:size(obj.vehicles,1)
                [addTime, mode] = obj.getMinDistance(obj.vehicles(i), requestIn);
                if((minAddTime == -1 || addTime < minAddTime) && (mode ~= -1))
                    minAddTime = addTime;
                    minMode = mode;
                    bestVehicle = obj.vehicles(i);
                    bestVehicleIndex = i;
                end
                
                if(minAddTime == 0)
                    break;
                end
            end
            
            switch(minMode)
                case -1 % Request can't be served within the timewindow
                    obj.unservedRequests{end+1} = requestIn;                
                case 1 % The request is fully on the way of a vehicle
                    % Append request to current requests
                    bestVehicle.assignedRequests{end+1} = requestIn;
                    bestVehicle.pickUps(end+1) = requestIn.pickUpNodeId;
                    bestVehicle.dropOffs(end+1) = requestIn.dropOffNodeId;
                    % Mark request as served
                    requestIn.served = true;
                case 2 % Only the pickup is on the way of the vehicle
                    bestVehicle.assignedRequests{end+1} = requestIn;
                    bestVehicle.pickUps(end+1) = requestIn.pickUpNodeId;
                    bestVehicle.dropOffs(end+1) = requestIn.dropOffNodeId;
                    % Append nodes between the last node of the vehicle and the dropOffNodeId 
                    nextNodes = obj.graph.getRoute(bestVehicle.nextNodes(end), requestIn.dropOffNodeId);
                    for i = 2:size(nextNodes,1)
                        bestVehicle.nextNodes(end+1) = nextNodes(i); 
                    end
                    % Mark request as served
                    requestIn.served = true;
                case 3 % The request is best served by a vehicle after its last dropoff
                    bestVehicle.assignedRequests{end+1} = requestIn;
                    bestVehicle.pickUps(end+1) = requestIn.pickUpNodeId;
                    bestVehicle.dropOffs(end+1) = requestIn.dropOffNodeId;
                    %Append nodes from the last dropoff top the pickup
                    if(size(bestVehicle.nextNodes,1) == 0)
                        nextNodes = obj.graph.getRoute(bestVehicle.depotNodeId, requestIn.pickUpNodeId);
                    else
                        nextNodes = obj.graph.getRoute(bestVehicle.nextNodes(end), requestIn.pickUpNodeId);
                    end
                    for i = 2:size(nextNodes,1)-1
                        bestVehicle.nextNodes(end+1) = nextNodes(i); 
                    end
                    %Append nodes from the pickup to the dropoff of the
                    %request
                    nextNodes = obj.graph.getRoute(requestIn.pickUpNodeId, requestIn.dropOffNodeId);
                    for i = 2:size(nextNodes,1)
                        bestVehicle.nextNodes(end+1) = nextNodes(i); 
                    end
                    % Mark request as served
                    requestIn.served = true;
                otherwise 
                    %Invalid case
            end
            
            if(minMode ~= -1)
                % Write back the best vehicle
                obj.vehicles(bestVehicleIndex) = bestVehicle;
            end

            % Return the requestIn variable, might have been modified
            requestOut = requestIn;
        end
        
        function [addTime, mode] = getMinDistance(obj, vehicle, requestIn)
            addTime = -1;
            mode = -1;
            % P and D are on the way
            containsP = any(ismember(vehicle.nextNodes, requestIn.pickUpNodeId));
            containsB = any(ismember(vehicle.nextNodes, requestIn.dropOffNodeId));
            if(containsP && containsB)
                %Check capacity
                if(size(vehicle.pickUps,1) < vehicle.capacity)
                    %Check pickup time
                    pTime = obj.time + vehicle.getTimeToNode(requestIn.pickUpNodeId, obj.edgeTime);
                    if(pTime>=requestIn.pickUpTimeEarliest)
                        %Check dropoff time
                        dTime = obj.time + vehicle.getTimeToNode(requestIn.dropOffNodeId, obj.edgeTime);
                        if(dTime <=requestIn.dropOffTimeLatest)
                            addTime = 0;
                            mode = 1;
                        end
                    end
                end
            elseif(containsP && ~containsB)
                %Check capacity
                if(size(vehicle.pickUps,1) < vehicle.capacity)
                    %Check pickup time
                    pTime = obj.time + vehicle.getTimeToNode(requestIn.pickUpNodeId, obj.edgeTime);
                    if(pTime>=requestIn.pickUpTimeEarliest)
                        %Check dropoff time
                        dTimeAdd = obj.graph.getDistance(vehicle.pos, requestIn.dropOffNodeId) * obj.edgeTime - vehicle.progress;
                        if(dTimeAdd + obj.time <=requestIn.dropOffTimeLatest)
                            addTime = dTimeAdd;
                            mode = 2;
                        end
                    end
                end
            end
            % If not in the way
            if(mode == -1)
                %No need to check capacity
                %Check if after the lost dropoff the vehicles can still
                %serve the request within the timewindow
                if(size(vehicle.nextNodes,1) == 0)
                    pTimeAdd = obj.graph.getDistance(vehicle.depotNodeId, requestIn.pickUpNodeId) * obj.edgeTime - vehicle.progress;
                else
                    pTimeAdd = obj.graph.getDistance(vehicle.nextNodes(end), requestIn.pickUpNodeId) * obj.edgeTime - vehicle.progress;
                end                
                dTimeAdd = obj.graph.getDistance(requestIn.pickUpNodeId, requestIn.dropOffNodeId) * obj.edgeTime - vehicle.progress;
                if(pTimeAdd + dTimeAdd + obj.time <=requestIn.dropOffTimeLatest)
                    addTime = pTimeAdd + dTimeAdd;
                    mode = 3;
                end
            end
        end
        
        function obj = allVehiclesStep(obj)
            for i = 1:size(obj.vehicles,1)
                vehic = obj.vehicles(i);
                % Check if vehicles is currently on a pickup location
                % (depot)
                if(any(ismember(vehic.pickUps, vehic.pos)))
                    % Remove node from pickups
                    vehic.pickUps = vehic.pickUps(vehic.pickups ~= vehic.pos);
                    % Add request to onBoardRequests
                    for j = 1:size(vehicle.assignedRequests)
                       req = vehicle.assignedRequests(j);
                       if(req.pickUpNodeId == vehic.pos && ...
                               req.pickUpTimeEarliest <= obj.time && ...
                               req.dropOffTimeLatest >= obj.time)
                           vehic.onBoardRequests(end+1) = req;
                       end
                    end
                    % Add onBoardRequests to passengersOnBoardAfterNode array
                    vehic.passengersOnBoardAfterNode(1) = vehic.onBoardRequests();
                end
                % Step
                vehic.progress = vehic.progress + 1;
                % Check if node is reached                
                if(vehic.progress == obj.edgeTime)
                    vehic.pos = vehic.nextNodes(1);
                    vehic.nextNodes(1) = [];
                    vehic.progress = 0;
                                        
                    % Check if pickup or dropoff is possible
                    if(any(ismember(vehic.pickUps, vehic.pos)))
                        % Remove node from pickups
                        vehic.pickUps = vehic.pickUps(vehic.pickUps ~= vehic.pos);
                        % Add request to onBoardRequests
                        for j = 1:size(vehic.assignedRequests)
                           req = vehic.assignedRequests{j};
                           if(req.pickUpNodeId == vehic.pos && ...
                                   req.pickUpTimeEarliest <= obj.time && ...
                                   req.dropOffTimeLatest >= obj.time)
                               vehic.onBoardRequests(end+1) = req;
                           end
                        end
                    elseif(any(ismember(vehic.dropOffs, vehic.pos)))
                        % Remove node from dropOffs
                        vehic.dropOffs = vehic.pickUps(vehic.dropOffs ~= vehic.pos);
                        % Remove request from onBoardRequests
                        for j = 1:size(vehic.assignedRequests)
                           if(vehic.assignedRequests(j).dropOffNodeId == vehic.pos && ...
                              vehic.assignedRequests(j).pickUpTimeEarliest <= obj.time && ...
                              vehic.assignedRequests(j).dropOffTimeLatest >= obj.time)
                               vehic.assignedRequests(j) = [];
                           end
                        end
                    end
                    
                    % Append node to whole route
                    vehic.completeRoute(end+1) = vehic.pos;
                    % Append current time to the nodes served array
                    vehic.nodeServedTime(end+1) = obj.time;
                    % Add onBoardRequests to passengersOnBoardAfterNode array
                    if(size(vehic.onBoardRequests,1) == 0)
                        vehic.passengersOnBoardAfterNode{end+1} = 0;
                    else
                        vehic.passengersOnBoardAfterNode{end+1} = vehic.onBoardRequests;
                    end                   
                end
                obj.vehicles(i) = vehic;
            end
        end
    end
end

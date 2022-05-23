classdef darpVehicle
    
   properties
       vehicleId;
       depotNodeId;
       capacity;
       
       nextNodes; %the list of the next nodes to visit
       pos; %current node
       progress; %the minutes spent travelling on this node
       pickUps; % the nodes, where a pickup will take place
       dropOffs; % the nodes, where a dropoff will take place
       
       % Solution data
       assignedRequests; % The list of all requests that are assigned to the vehicle
       onBoardRequests; %the list of all requests that are currently being served
       completeRoute;
       nodeServedTime;
       passengersOnBoardAfterNode;
       requestsCompleted;
       
   end
   
    methods
        function obj = clearSolutionData(obj)
            obj.onBoardRequests = [];
            obj.assignedRequests = [];
            obj.nextNodes = [];
            obj.pickUps = [];
            obj.dropOffs = [] ;
            
            obj.completeRoute = [obj.depotNodeId];
            obj.nodeServedTime = [0];
            obj.passengersOnBoardAfterNode = {0};
            obj.requestsCompleted = [];

            obj.progress = 0;
        end

        function time = getTimeToNode(obj, nodeId, edgeTime)
            if(any(ismember(obj.nextNodes, nodeId)))
                time = edgeTime - obj.progress;
                for i = 2:size(obj.nextNodes,2)
                    if(obj.nextNodes(i) == nodeId)
                        break;
                    else
                        time = time + edgeTime;
                    end
                end
            else
                time = -1;
            end
        end
    end
   
   methods (Access = private)
   
   end
    
end
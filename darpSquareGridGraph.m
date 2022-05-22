classdef darpSquareGridGraph
    %darpGraph graph class
    %
    
    properties
        sideLength;
        nNodes;
        nArcs;
        
        nodeCoords; %nodes with x, y
        arcCoords; %arcs with x1, y1, x2, y2
        adjMat;
    end
    
    methods
        %Constructor
        function obj = darpSquareGridGraph(sideLenInput)
            obj.sideLength = sideLenInput;
            obj.nNodes = obj.sideLength^2;
            obj.nArcs = 2*obj.sideLength*(obj.sideLength-1);
            
            obj = obj.generateAdjMat();
            obj = obj.calculateCoordinates();
        end
        
        function distance = getDistance(obj, node1, node2)
            node1row = obj.nodeCoords(node1,1);
            node1col = obj.nodeCoords(node1,2);
            node2row = obj.nodeCoords(node2,1);
            node2col = obj.nodeCoords(node2,2);
            distance = abs(node1row - node2row) + abs(node1col - node2col); 
        end
        
        function route = getRoute(obj, node1, node2)
            node1row = obj.nodeCoords(node1,1);
            node1col = obj.nodeCoords(node1,2);
            node2row = obj.nodeCoords(node2,1);
            node2col = obj.nodeCoords(node2,2);
            
            allCoords = zeros(obj.getDistance(node1, node2) + 1,2);
            j = 0;
            % Go to the same column
            if(node1col<=node2col)
                cols = node1col:node2col;
            else
                cols = node1col:-1:node2col;
            end
            
            for i = cols
                j=j+1;
                allCoords(j,1) = node1row;
                allCoords(j,2) = i;
            end
            
            % Go to thesame row
            j = j-1;
            if(node1row<=node2row)
                rows = node1row:node2row;
            else
                rows = node1row:-1:node2row;
            end
            
            for i = rows
                j=j+1;
                allCoords(j,1) = i;
                allCoords(j,2) = node2col;
            end
            
            route = zeros(j,1);
            for i = 1:j
                plom = ismember(obj.nodeCoords(:,1), allCoords(i,1)) + ismember(obj.nodeCoords(:,2), allCoords(i,2));
                found = find(plom == 2);
                route(i) = found;
            end
        end
    end
    
    methods (Access = private)
        function obj = generateAdjMat(obj)           
            %generateAdjMat generates the adjecency matrix for the square
            %grid graph with the given sideLength
            
            M = zeros(obj.nNodes);
            for r = 1:obj.sideLength
                for c = 1:obj.sideLength
                    i = (r-1) * obj.sideLength + c;
                    if(c>1) %Two inner diagonals
                        M(i-1,i) = 1;
                        M(i,i-1) = 1;
                    end
                    if(r>1) %Two outer diagonals
                        M(i-obj.sideLength, i) = 1;
                        M(i,i-obj.sideLength) = 1;
                    end
                end
            end
            obj.adjMat = M;     
        end
        
        function obj = calculateCoordinates(obj)
            %calculate the coordinates of the nodes
            obj.nodeCoords = zeros(obj.nNodes, 2);
            for r = 1:obj.sideLength
                for c = 1:obj.sideLength
                    i = (r-1) *obj.sideLength + c;
                    obj.nodeCoords(i,1) = r-1;
                    obj.nodeCoords(i,2) = c-1;
                end
            end
            
            %calculate the coordinates of the arcs
            obj.arcCoords = zeros(obj.nArcs,4);
            counter = 0;
            %iterate over the whole adjMat
            for r = 1:obj.nNodes
                for c = (r+1):obj.nNodes
                    if(obj.adjMat(r,c) == 1)
                        counter = counter + 1;
                        obj.arcCoords(counter,:) = [obj.nodeCoords(r,:), obj.nodeCoords(c,:)];
                    end
                end
            end
        end
    end
end


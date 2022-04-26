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


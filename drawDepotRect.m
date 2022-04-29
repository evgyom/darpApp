function retImg = drawDepotRect(imgIn, xMin, yLeft, height, width, fillColor)
    % drawDot draws a dot to the given position 
    % params:
    %   - imgIn: the image to draw on
    %   - xMin: 
    %   - yLeft:
    %   - height:
    %   - width:
    %   - fillColor:
    
    xMax = xMin + height;
    yRight = yLeft + width;
    
    if(xMax>size(imgIn,1) || yRight>size(imgIn,2) || xMin<0 || yLeft<0)
        error("Coordinates are outside the image.")
    end
           
    retImg = imgIn;
    for x = xMin : xMin + height
        for y = yLeft : yLeft + width
            %Fill
            if(x>=xMin || x <= xMax || y >= yLeft || y<=yRight) 
                retImg(x,y,:) = fillColor;
            end
        end
    end
end

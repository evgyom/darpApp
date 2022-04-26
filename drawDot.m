function retImg = drawDot(imgIn, xCenter, yCenter, radius, borderColor, borderWidth, fillColor1, fillColor2)
    % drawDot draws a dot to the given position 
    % params:
    %   - imgIn: the image to draw on
    %   - xCenter, yCenter: the center coordinates of the dot
    %   - radius: the radius of the dor
    %   - borderColor: 
    %   - borderWidth: px
    %   - fillColor1:
    %   - fillColor2: if not NULL the right half is filled with this color
    
    if((xCenter+radius) > size(imgIn,1) || (yCenter+radius) > size(imgIn,2) || ...
            (xCenter-radius) < 0 || (yCenter-radius) <0)
        error("Coordinates are outside the image.")
    end
        
    %Check if fillColor2 is a valid color
    doubleColor = false;
    if(all(size(fillColor2) == [1,3]))
        if(fillColor2(1)<=255 && fillColor2(1)>=0 && ... 
            fillColor2(2)<=255 && fillColor2(2)>=0 && ... 
            fillColor2(3)<=255 && fillColor2(3)>=0)
            doubleColor = true;
        end
    end
    
    retImg = imgIn;
    for x = xCenter - radius : xCenter + radius
        for y = yCenter - radius : yCenter + radius
            %Border
            if((((x-xCenter)^2 + (y - yCenter)^2) < radius^2) && ...
                (((x-xCenter)^2 + (y - yCenter)^2) >= (radius-borderWidth)^2))
                retImg(x,y,:) = borderColor;
            end
            %Fill
            if(((x-xCenter)^2 + (y - yCenter)^2) < (radius-borderWidth)^2)
                if(doubleColor && y>yCenter)
                    retImg(x,y,:) = fillColor2;
                else
                    retImg(x,y,:) = fillColor1;
                end
            end
        end      
    end       
end
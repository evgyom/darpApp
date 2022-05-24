function retImg = drawLine(imgIn, x1, y1, x2, y2, color, lineWidth)
    %drawLine draws a line on the given image with the given color
    % params:
    %   - imgIn: the image to draw on
    %   - x1, y1: the starting point of the line
    %   - x2, y2: the end point of the line
    %   - radius: the radius of the dor
    %   - color: line color
    %   - lineWidth: px
    
    Height =  size(imgIn,1);
    Width =  size(imgIn,2);
    %Validating input
    if(x1 > Width || x2 > Width || y1 > Height || y2>Height || ...
            x1<0 || x2<0 || y1<0 || y2<0)
        error("Start or end coordinates are outside the image.") 
    end
    
    %Check if the line width is even or odd
    widthEven = false;
    if(mod(lineWidth,2) == 0)
        widthEven = true;
    end
  
    retImg = imgIn;
    if(y1 ~= y2)
        % Not vertical line
        m = (x2-x1) / (y2 - y1);
        b = x1 - m*y1;
        for y = min(y1,y2):max(y1,y2)
            x = round(m*y + b);
            if(widthEven)
                for x_width = (x-lineWidth/2) : (x+lineWidth/2-1)
                    retImg(x_width,y,:) = color;
                end
            else
                for x_width = (x-(lineWidth-1)/2) : (x+(lineWidth-1)/2) 
                    retImg(x_width,y,:) = color;
                end
            end
        end
    else
        %The line is vertical
        for x = min(x1,x2):max(x1,x2)
            if(widthEven)
                for y_width = (y1-lineWidth/2) : (y1+lineWidth/2-1)
                    retImg(y_width,x,:) = color;
                end
            else
                for y_width = (y1-floor(lineWidth/2)) : (y1+floor(lineWidth/2))
                    retImg(x,y_width,:) = color;
                end
            end
        end
    end
end
function [ dispMap ] = DISPARITYMAP( imgL, imgR, scanwinsize )
    %The function takes in the left and right grayscale stereo pair as imgl
    %and imgr resp.And the size of the scanning window scanwinsize.Its an
    %improvement over the method as it computes in a region around the
    %pixel i.e compares the windows.

    maxrows = size(imgL, 1) -scanwinsize +1 ;
    maxcols = size(imgL, 2) -scanwinsize +1 ;
    
    Scale= 3; %Right Search Window Scale
    for row = 1: maxrows
         disp(['Processing Row ',num2str(row), ' of ', num2str(maxrows)]);
        for col = 1: maxcols  
            WL = ScanWindow(imgL, col, row, scanwinsize, 1);      
            WRwidth = scanwinsize*Scale;            
            WRcol = col - (scanwinsize * ((Scale-1)/2)) - ((scanwinsize-1)/2);  
            WRrow = row ;
            if (WRcol < 1)
                WRcol = 1;
            end           
            if (WRcol >  size(imgL, 2) - WRwidth + 1)
                WRcol =  size(imgL, 2) - WRwidth + 1;
            end
            if (WRrow < 1)
                WRrow = 1;
            end
            if (WRrow > size(imgL, 1) - WRwidth + 1)
                WRrow = size(imgL, 1) - WRwidth + 1;
            end   
            WR = ScanWindow(imgR, WRcol, WRrow, scanwinsize, Scale);             
            pixMatch = 1;
            dispMax = -10000000;
            range = (Scale * scanwinsize) - (scanwinsize -1 );
            pixOrig = ((range - 1) / 2) + 1;
            for yrCurr = 1 : 1 + (size(WR, 1) -scanwinsize)
                for xrCurr = 1 : 1 + (size(WR, 2) - scanwinsize)
                    scanner = ScanWindow(WR, xrCurr, yrCurr, scanwinsize, 1);                    
                    similarity = SSD(WL, scanner);                    
                    if (similarity > dispMax)
                        dispMax = similarity;
                        pixMatch = xrCurr;   
                    end
                end
            end
            dispvector = pixOrig - pixMatch;
            dispVal = (255 / (pixOrig -1)) * abs(dispvector);            
            dispMap(row, col, 1) = uint8(dispVal);
        end
    end  
end


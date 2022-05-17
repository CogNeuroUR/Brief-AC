function [out] = rearrangeTiles(in)
%in=thisPic;
[nRows, nCols, nDim] = size(in);
out = in; %make copy of original
tileSize = 10;%10;

nTilesPerRow = nRows/tileSize;
nTilesPerCol = nCols/tileSize;

%randomizeTiles
for i = 1 : nTilesPerRow
    for j = 1 : nTilesPerCol
        thisRandVecCols = randperm(nTilesPerCol);
        thisRandVecRows = randperm(nTilesPerRow);
        %RGB
        thisTile = in(i*tileSize-(tileSize-1):i*tileSize, j*tileSize-(tileSize-1):j*tileSize, :);
        %grayscale
        %thisTile = in(i*tileSize-(tileSize-1):i*tileSize, j*tileSize-(tileSize-1):j*tileSize);
        
        %thisFlip = randperm(4,1);
        thisFlip = randperm(3,1);
        
        if thisFlip == 1
            thisTile = rot90(thisTile);
        elseif thisFlip ==2
            thisTile = flipud(thisTile);
        elseif thisFlip == 3
            thisTile = fliplr(thisTile);
        else
            %do nothing
        end
        
        %RGB
        out(thisRandVecRows(i)*tileSize-(tileSize-1):thisRandVecRows(i)*tileSize, thisRandVecCols(j)*tileSize-(tileSize-1):thisRandVecCols(j)*tileSize,:)=thisTile;
        %grayscale
        %       out(thisRandVecRows(i)*tileSize-(tileSize-1):thisRandVecRows(i)*tileSize, thisRandVecCols(j)*tileSize-(tileSize-1):thisRandVecCols(j)*tileSize)=thisTile;
        
    end
end
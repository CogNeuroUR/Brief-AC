function out=scrambledsingle(in)
% figure;
% imshow(out);
out=in;
tileSize=10;
%do it again
% t=1
% % %
nTilesPerRow2=size(in,1)/tileSize;
nTilesPerCol2=size(in,2)/tileSize;
for i = 1 : nTilesPerRow2
    for j = 1 : nTilesPerCol2
        thisRandVecCols2 = randperm(nTilesPerCol2);
        thisRandVecRows2 = randperm(nTilesPerRow2);
        thisTile = out(i*tileSize-(tileSize-1):i*tileSize, j*tileSize-(tileSize-1):j*tileSize, :);
        
        thisFlip = randperm(4,1);
        %thisFlip = thisFlip
        if thisFlip == 1
            thisTile = rot90(thisTile);
        elseif thisFlip ==2
            thisTile = flipud(thisTile);
        elseif thisFlip == 3
            thisTile = fliplr(thisTile);
        else
            %do nothing
        end
                
        %out(randVecRows(i)*tileSize-(tileSize-1):randVecRows(i)*tileSize, randVecCols(j)*tileSize-(tileSize-1):randVecCols(j)*tileSize,:)=thisTile;
        out(thisRandVecRows2(i)*tileSize-(tileSize-1):thisRandVecRows2(i)*tileSize, thisRandVecCols2(j)*tileSize-(tileSize-1):thisRandVecCols2(j)*tileSize,:)=thisTile;
        %imagesc(out);
    end
end
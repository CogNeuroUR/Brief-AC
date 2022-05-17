function createMasks

%pathToStim = [pwd, '\stimuli\'];
pathToStim = [pwd, '/stimuli/'];

fNameList = dir([pathToStim '*.png']);
nStim = length(fNameList);

for i = 1 : nStim
    [pathstr, thisName, ext] = fileparts(fNameList(i).name); 
    thisPic = imread([pathToStim fNameList(i).name]);
    thisPicMasked = rearrangeTiles(thisPic);
    sName = [pathToStim sprintf('mask_%s.png', thisName)];
    imwrite(thisPicMasked, sName);
    t = 1;
    
end
%fclose(fid);


function [out] = rearrangeTiles(in)

[nRows, nCols, nDim] = size(in);
out = in; %make copy of original
tileSize = 20;%10;

%disp(class(nRows));
%disp(class(nCols));

nTilesPerRow = fix(nRows/tileSize);
nTilesPerCol = fix(nCols/tileSize); %nCols/tileSize;

%randomizeTiles
for i = 1 : nTilesPerRow
    for j = 1 : nTilesPerCol
        thisRandVecCols = randperm(nTilesPerCol);
        thisRandVecRows = randperm(nTilesPerRow);
        %RGB
        %thisTile = in(i*tileSize-(tileSize-1):i*tileSize, j*tileSize-(tileSize-1):j*tileSize, :);
        %grayscale
        thisTile = in(i*tileSize-(tileSize-1):i*tileSize, j*tileSize-(tileSize-1):j*tileSize);
        
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
        %out(thisRandVecRows(i)*tileSize-(tileSize-1):thisRandVecRows(i)*tileSize, thisRandVecCols(j)*tileSize-(tileSize-1):thisRandVecCols(j)*tileSize,:)=thisTile;
        %grayscale
        out(thisRandVecRows(i)*tileSize-(tileSize-1):thisRandVecRows(i)*tileSize, thisRandVecCols(j)*tileSize-(tileSize-1):thisRandVecCols(j)*tileSize)=thisTile;
    end
end

%figure;
%imshow(out);
%do it again
t=1
% % 
for i = 1 : nTilesPerRow
    for j = 1 : nTilesPerCol
        thisRandVecCols = randperm(nTilesPerCol);
        thisRandVecRows = randperm(nTilesPerRow);
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
        out(thisRandVecRows(i)*tileSize-(tileSize-1):thisRandVecRows(i)*tileSize, thisRandVecCols(j)*tileSize-(tileSize-1):thisRandVecCols(j)*tileSize,:)=thisTile;
        imagesc(out);
        t = 1;
    end
end

%figure;
%imshow(out);

t=1;

t=1
        
        
        
        
        
        

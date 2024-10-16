%%% This script is used to read the binary file produced by the DCA1000
%%% and Mmwave Studio
%%% Command to run in Matlab GUI - readDCA1000('<ADC capture bin file>')

function [retVal] = readDCA1000_inChunks(fileName)
    % global variables
    numADCBits = 16; % number of ADC bits per sample
    numLanes = 4; % number of lanes is always 4
    isReal = 0; % set to 1 if real data, 0 if complex data
    chunkSize = 1e5; % Number of samples to read at a time

    % Open the file
    fid = fopen(fileName, 'r');
    if fid == -1
        error('Error opening the file.');
    end

    % Initialize variables
    retVal = [];
    
    while ~feof(fid)
        % Read in a chunk of data
        adcDataChunk = fread(fid, [numLanes*2, chunkSize], 'int16');
        if isempty(adcDataChunk)
            break;
        end
        
        % If 12 or 14 bits ADC per sample, compensate for sign extension
        if numADCBits ~= 16
            l_max = 2^(numADCBits-1)-1;
            adcDataChunk(adcDataChunk > l_max) = adcDataChunk(adcDataChunk > l_max) - 2^numADCBits;
        end

        % Process complex data
        % Reshape and combine real and imaginary parts
        adcData = reshape(adcData, numLanes*2, []);
        realPart = adcDataChunk(1:numLanes, :);
        imagPart = adcDataChunk(numLanes+1:end, :);
        adcDataChunk = realPart + sqrt(-1) * imagPart;
        
        % Append processed chunk to retVal
        retVal = [retVal, adcDataChunk];  % Concatenate chunks
    end
    
    % Close the file
    fclose(fid);
end

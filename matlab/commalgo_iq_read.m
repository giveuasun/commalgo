function [data, fs] = commalgo_iq_read(filename)
% Designed by gvs on 2026.9.28 for easy IQ data loading.
    [audioData, fs] = audioread(filename);
    [~, numChannels] = size(audioData);
    if numChannels < 2
        error('not iq');
    end
    data = audioData(:,1)+1j*audioData(:,2);
end


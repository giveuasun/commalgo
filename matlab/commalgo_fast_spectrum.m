function commalgo_fast_spectrum(data, len)
    % Designed for fast waterfall plotting.
    % Redesigned by giveuasun on 2026.9.24.
    % version: v1
    if nargin < 2 || isempty(len), len = 256; end
    noverlap = len * 0.75;
    nfft = len;
    [S, F, T] = spectrogram(data, len, noverlap, nfft, 1, 'centered');
    
    figure;
    imagesc(T, F, 10*log10(abs(S)));
    axis xy;
    colorbar;           % 增加能量色标
%     colormap('parula'); % 设置更清晰的配色
    colormap('turbo');
    xlabel('采样点 (个)'); 
    ylabel('归一化频率 ( -0.5 ~ 0.5 )');
    title('快速时频图');
end


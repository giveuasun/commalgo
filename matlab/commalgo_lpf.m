function data = commalgo_lpf(data, fs, f_cutoff)
% 低通滤波器
%   data: 输入信号数据
%   fs: 采样率
%   f_cutoff: 截止频率
    data = lowpass(data, f_cutoff, fs);
end


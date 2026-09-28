function first_peak_idx = commalgo_find_first_peak(c, threshold, i)
% 寻找首峰函数，restored by giveuasun on 2026.9.28
% input: c:图像曲线 threshold：阈值 i：搜索起点索引
% output：返回大于阈值的第一个峰索引，如果没找到则返回-1。
    if nargin < 2 || isempty(threshold), threshold = 0.7; end
    if nargin < 3 || isempty(i), i = 2; end
    N = length(c);
    if i<2 || i>N-1 || N<3
        first_peak_idx = -1;
        return;
    end
    while i < N
        if (c(i) > threshold) && (c(i) > c(i-1)) && (c(i) >= c(i+1))
            first_peak_idx = i; 
            return;
        end
        i = i + 1;
    end
    first_peak_idx = -1;
end

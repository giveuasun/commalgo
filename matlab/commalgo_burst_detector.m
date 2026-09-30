function [burst_pos, burst_len] = commalgo_burst_detector(data, win_len, snr)
% recoded by giveuasun on 2026.9.28 (Reviewed & Optimized by AI)
% input :    snr: 突发高于底噪的比值    win_len: 双滑窗单窗窗长
% output :   burst_pos: 突发起点位置向量  burst_len: 突发长度向量  

    burst_pos = [];
    burst_len = [];
    len = length(data);
    
    if len < 2 * win_len
        error('bad input');
    end

    s_power = data .* conj(data); % 信号瞬时能量
    
    % 计算单窗功率（滑动窗口优化）
    window_power = zeros(len - win_len + 1, 1);
    for i = 1:length(window_power)
        if i == 1
            window_power(i) = sum(s_power(1:win_len));
        else
            window_power(i) = window_power(i - 1) - s_power(i - 1) + s_power(i + win_len - 1);
        end
    end
    window_power = window_power / win_len;
    
    % 双滑窗比值（加入微小量 eps 防止分母为零）
    window_div = window_power(win_len + 1 : end) ./ (window_power(1 : end - win_len) + eps);
    
    % 寻找突发开始与结束
    burst_begin_pos = -1;
    burst_num = 0;
    
    for i = 1:length(window_div)
        if burst_begin_pos <= 0 && window_div(i) > snr
            burst_begin_pos = i;
        elseif burst_begin_pos > 0 && window_div(i) < 1.0 / snr
            burst_end_pos = i + 2 * win_len;
            burst_num = burst_num + 1;
            burst_pos(burst_num) = burst_begin_pos;
            burst_len(burst_num) = burst_end_pos - burst_begin_pos + 1;
            burst_begin_pos = -1;
        end
    end
    
    % 【新增】处理循环结束时仍未闭合的突发
    if burst_begin_pos > 0
        burst_end_pos = length(window_div) + 2 * win_len;
        burst_num = burst_num + 1;
        burst_pos(burst_num) = burst_begin_pos;
        % 确保不超过数据总长度
        burst_len(burst_num) = min(len, burst_end_pos) - burst_begin_pos + 1;
    end
end

% function [burst_pos,burst_len] = commalgo_burst_detector(data,win_len,snr)
% % recoded by giveuasun on 2026.9.28
% % input :   snr:突发高于底噪的比值   win_len:双滑窗单窗窗长
% % output :  burst_pos:突发起点位置向量  burst_len:突发长度向量  
%     burst_pos = [];
%     burst_len = [];
%     len = length(data);
%     s_power = data .* conj(data);%信号能量
%     % 计算窗功率
%     window_power = zeros(len - win_len + 1,1);
%     for i=1:length(window_power)
%         if i==1
%             window_power(i) = sum(s_power(1:win_len));
%         else
%             window_power(i) = window_power(i -1) - s_power(i-1) + s_power(i + win_len - 1);
%         end
%     end
%     window_power = window_power/win_len;
%     % 双滑窗比值
%     window_div =  window_power(win_len+1:end) ./ window_power(1:end-win_len) ;
%     % 寻找突发开始结束
%     burst_begin_pos = -1;
%     burst_num = 0;
%     for i=1:length(window_div)
%         if burst_begin_pos <= 0 && window_div(i)> snr
%             burst_begin_pos = i;
%         elseif burst_begin_pos > 0 && window_div(i)< 1.0/snr
%             burst_end_pos = i + 2*win_len;
%             burst_num = burst_num + 1;
%             burst_pos(burst_num) = burst_begin_pos;
%             burst_len(burst_num) = burst_end_pos - burst_begin_pos + 1;
%             burst_begin_pos = -1;
%         end
%     end
% end
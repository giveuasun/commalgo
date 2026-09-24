function data_out = commalgo_based_cp_auto_corr(data, cp_len, sb_len)
% scope:ofdm系统利用cp实现cfo纠正
% input：data：突发信号 cp_len:循环前缀点数 sb_len:不包含cp的原始ofdm符号长度
% output：data：纠正后的信号

% designed by givuasun on 2026.9.3.

    % 输入校验
    if length(data) < cp_len + sb_len || cp_len > sb_len
        error('bad input');
    end

    % 自相关原始值计算
    c1 = data(1:end - sb_len) .* conj(data(1 + sb_len:end));
    c2 = zeros(length(c1) - cp_len + 1, 1);
    for i = 1 : length(c2)
        if i == 1
            c2(i) = sum(c1(1:cp_len));
        else
            c2(i) = c2(i - 1) - c1(i - 1) + c1(i + cp_len - 1);
        end
    end
    c2 = abs(c2) .^ 2;

    % 归一化参数计算
    e1 = abs(data) .^ 2;
    e2 = zeros(length(e1) - cp_len + 1, 1);
    for i=1:length(e2)
        if i==1
            e2(i) = sum(e1(1:cp_len));
        else
            e2(i) = e2(i - 1) - e1(i - 1) + e1(i + cp_len - 1);
        end
    end
    e3 = e2(1:end - sb_len) .* e2(sb_len + 1 : end);

    % 归一化自相关谱
    corr = c2 ./ (e3 + eps);
    figure;plot(corr);

    % 峰值判定
    % 提高鲁棒性，只取最强峰
    [~, idx] = max(corr);


    % 小数倍数cfo估计与纠正
    data = data(:);
    w1 = data(idx : idx + cp_len - 1);
    w2 = data(idx + sb_len : idx + sb_len + cp_len - 1);
    p = w1' * w2;
    cfo_est = angle(p) / (2 * pi * sb_len);
    
    t_axis = (0 : length(data) - 1).'; 
    data_out = data .* exp(-1j * 2 * pi * cfo_est * t_axis);

end
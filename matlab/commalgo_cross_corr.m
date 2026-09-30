function corr = commalgo_cross_corr(uw, data, search_start, search_end)
% 归一化互相关函数 Normalized cross-correlation function
% Refactored by giveuasun on 2026.9.24.
    if length(data) < search_end + length(uw) - 1
        error('bad input');
    end

    search_data = data(search_start : search_end + length(uw) - 1);
    search_data_energy = abs(search_data).^2;
    uw_energy = sum(abs(uw).^2);
    search_data_energy = search_data_energy * uw_energy;

    cnt = search_end - search_start + 1;
    corr = zeros(cnt, 1);

    R = 0;
    for i = 1 : cnt
        win = data(search_start + i - 1 : search_start + i - 1 + length(uw) - 1);
        P = sum(win(:) .* conj(uw(:)));
        if i == 1
            R = sum(search_data_energy(1:length(uw)));
        else
            R = R - search_data_energy(i-1) + search_data_energy(i + length(uw) - 1);
        end
        corr(i) = abs(P.^2)/(R+eps);
    end
end

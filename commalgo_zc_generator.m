function zc_seq = commalgo_zc_generator(N, q, carrier_spacing, target_fs)
% zhadoff-chu sequence generator for DJI drone ID
% input：N: zc序列长度（一般为素数） q：根指数，dji用到600，147 carrier_spacing：子载波间隔 target_fs：输出采样率
% output：zc_seq：经过映射和ofdm调制的zc序列
% optimized by giveuasun in 2026.9.

    is_N_prime = isprime(N);
    % if(~isprime(N))
    %     fprintf("Number N: %.1f is not prime.", N);
    %     return;
    % end

    % if (~rem(N,q))
    %     fprintf("N(%i)/q(%i)=%.1f, exact division is not allowed .", N,q,N/q);
    %     return;
    % end

    idx = ceil(log2(N));
    carrier_n = 2^idx;
    n = (0:N-1)';
    % n = -(N-1)/2:(N-1)/2';

    zc = exp(-1i * pi * q * n .* (n+1) / N);

    if is_N_prime
        starting_i = (carrier_n - N + 1) / 2;
        zc_loc = [starting_i+1 : starting_i + N]';
        dc_loc = (N - 1) / 2;
        zc_loc(dc_loc + 1) = [];
        zc((N-1)/2 + 1) = [];
    else

        starting_i = (carrier_n - N) / 2;
        zc_loc = [starting_i+1 : starting_i + N]';
    end

    % zc = fftshift(zc);

    zc_seq = complex(zeros(carrier_n,1));
    zc_seq(zc_loc) = zc;
    zc_seq = ifft(fftshift(zc_seq));
    source_fs = carrier_spacing * carrier_n;
    if target_fs ~= source_fs
        zc_seq = resample(zc_seq, target_fs, source_fs);
    end
    zc_seq = zc_seq / max(abs(zc_seq));
end 
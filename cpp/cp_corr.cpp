#include <vector>
#include <complex>
#include <cmath>
#include <algorithm>
#include <iostream>

using Complex = std::complex<double>;
using ComplexVec = std::vector<Complex>;


/**
 * @brief 利用 OFDM CP 完成小数倍 CFO 估计/纠正
 *
 * @param data   输入/输出 IQ 数据，函数执行后直接被 CFO 纠正
 * @param cp_len 循环前缀长度
 * @param sb_len OFDM 有效符号长度
 *
 * @return true  : 处理成功
 * @return false : 输入参数错误
 */
bool cp_corr(ComplexVec& data, int cp_len, int sb_len)
{
    // =========================
    // 1. 输入校验
    // =========================
    if (cp_len <= 0 ||
        sb_len <= 0 ||
        cp_len > sb_len ||
        data.size() < static_cast<size_t>(cp_len + sb_len))
    {
        return false;
    }

    const int N = static_cast<int>(data.size());

    // =========================
    // 2. 计算原始自相关
    //
    // c1(i) =
    // data(i) * conj(data(i + sb_len))
    // =========================
    const int c1_len = N - sb_len;

    std::vector<Complex> c1(c1_len);

    for (int i = 0; i < c1_len; ++i)
    {
        c1[i] = data[i] * std::conj(data[i + sb_len]);
    }

    // =========================
    // 3. CP 长度滑动相关
    // =========================
    const int c2_len = c1_len - cp_len + 1;

    std::vector<double> c2(c2_len);

    Complex corr_sum(0.0, 0.0);

    // 第一个窗口
    for (int i = 0; i < cp_len; ++i)
    {
        corr_sum += c1[i];
    }

    c2[0] = std::norm(corr_sum);

    // 滑动窗口
    for (int i = 1; i < c2_len; ++i)
    {
        corr_sum -= c1[i - 1];
        corr_sum += c1[i + cp_len - 1];

        c2[i] = std::norm(corr_sum);
    }

    // =========================
    // 4. 计算输入信号能量
    // =========================
    std::vector<double> e1(N);

    for (int i = 0; i < N; ++i)
    {
        e1[i] = std::norm(data[i]);
    }

    // =========================
    // 5. CP 长度滑动能量
    // =========================
    const int e2_len = N - cp_len + 1;

    std::vector<double> e2(e2_len);

    double energy_sum = 0.0;

    // 第一个窗口
    for (int i = 0; i < cp_len; ++i)
    {
        energy_sum += e1[i];
    }

    e2[0] = energy_sum;

    // 滑动窗口
    for (int i = 1; i < e2_len; ++i)
    {
        energy_sum -= e1[i - 1];
        energy_sum += e1[i + cp_len - 1];

        e2[i] = energy_sum;
    }

    // =========================
    // 6. 归一化相关值
    //
    // corr = c2 / (e2(i) * e2(i+sb_len))
    // =========================
    const int corr_len = e2_len - sb_len;

    std::vector<double> corr(corr_len);

    constexpr double EPS = 1e-12;

    for (int i = 0; i < corr_len; ++i)
    {
        double denominator = e2[i] * e2[i + sb_len];
        corr[i] = c2[i] / (denominator + EPS);
    }

    // =========================
    // 7. 找最大峰值
    // =========================
    auto max_it = std::max_element(corr.begin(), corr.end());

    int idx = static_cast<int>(
            std::distance(corr.begin(), max_it)
        );
    // =========================
    // 8. CFO 估计
    // p = w1' * w2
    // w1 = data[idx : idx+cp_len-1]
    // w2 = data[idx+sb_len : idx+sb_len+cp_len-1]
    // =========================
    Complex p(0.0, 0.0);

    for (int i = 0; i < cp_len; ++i)
    {
        p += std::conj(data[idx + i]) * data[idx + sb_len + i];
    }
    // =========================
    // 9. 小数倍 CFO
    // =========================
    constexpr double PI = 3.14159265358979323846;

    double cfo_est = std::arg(p) / (2.0 * PI * static_cast<double>(sb_len));
    // =========================
    // 10. 原地 CFO 纠正
    // =========================
    for (int i = 0; i < N; ++i)
    {
        double phase = -2.0 * PI * cfo_est * static_cast<double>(i);
        Complex correction = std::exp(Complex(0.0, phase));
        data[i] *= correction;
    }
    return true;
}



#include <iostream>

int main()
{
    ComplexVec data;

    // 假设这里已经获得 IQ 数据
    data.resize(4096);

    int cp_len = 64;
    int sb_len = 256;

    // 原地 CFO 纠正
    bool success = cp_corr(data, cp_len, sb_len);

    if (!success)
    {
        std::cerr << "cp_corr failed!" << std::endl;
        return -1;
    }

    std::cout << "CFO correction finished." << std::endl;
    std::cout << "samples = "
              << data.size()
              << std::endl;

    return 0;
}
#include "blood_pressure.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>

// 静态全局变量
static float systolic_coeff = 1.25f;    // 收缩压系数
static float diastolic_coeff = 0.89f;   // 舒张压系数
static float pwtt_base = 200.0f;        // 基准传输时间
static float base_systolic = 120.0f;    // 基准收缩压
static float base_diastolic = 80.0f;    // 基准舒张压

void extract_wave_features(const uint32_t *ppg_buffer, uint16_t len, WaveFeatures_t *features) 
{
    uint32_t max_val = 0, min_val = UINT32_MAX;
    uint16_t max_idx = 0, min_idx = 0;
    float sum_area = 0;

    // 寻找波峰波谷
    for (uint16_t i = 1; i < len-1; i++) {
        // 峰值检测
        if (ppg_buffer[i] > ppg_buffer[i-1] && 
            ppg_buffer[i] > ppg_buffer[i+1] && 
            ppg_buffer[i] > max_val) 
        {
            max_val = ppg_buffer[i];
            max_idx = i;
        }
        
        // 谷值检测
        if (ppg_buffer[i] < ppg_buffer[i-1] && 
            ppg_buffer[i] < ppg_buffer[i+1] && 
            ppg_buffer[i] < min_val) 
        {
            min_val = ppg_buffer[i];
            min_idx = i;
        }
    }

    // 计算波形特征
    features->rise_time = (max_idx > min_idx) ? 
                         (max_idx - min_idx) * 10.0f :  // 采样率100Hz转ms
                         0.0f;
    
    features->peak_amp = (max_val > min_val) ? 
                        (float)(max_val - min_val) : 
                        0.0f;
    
    // 计算波形面积比（梯形积分法）
    if (max_idx > min_idx && max_val != min_val) {
        for (uint16_t i = min_idx; i < max_idx; i++) {
            float y1 = (float)(ppg_buffer[i] - min_val);
            float y2 = (float)(ppg_buffer[i+1] - min_val);
            sum_area += (y1 + y2) / 2.0f;  // 梯形面积
        }
        features->area_ratio = sum_area / (features->peak_amp * (max_idx - min_idx));
    } else {
        features->area_ratio = 0.0f;
    }
    
    // 估算脉搏波传输时间（PTT）
    features->pwtt = (features->rise_time > 0.1f) ? 
                    (pwtt_base / features->rise_time) : 
                    0.0f;
}

void calculate_blood_pressure(const WaveFeatures_t *features, BloodPressure_t *result) 
{
    // 参数有效性检查
    if (features == NULL || result == NULL) return;
    
    // 使用动态校准系数计算血压
    result->systolic = (int32_t)(
        base_systolic + 
        features->rise_time * 0.5f -
        features->peak_amp * 0.002f +
        features->pwtt * systolic_coeff
    );
    
    result->diastolic = (int32_t)(
        base_diastolic + 
        features->rise_time * 0.3f +
        features->peak_amp * 0.001f +
        features->pwtt * diastolic_coeff
    );
    
    // 数据有效性验证
    result->valid = (
        result->systolic > 80 && 
        result->systolic < 200 &&
        result->diastolic > 40 && 
        result->diastolic < 120 &&
        features->rise_time >= 50.0f &&   // 正常上升时间范围
        features->rise_time <= 300.0f &&
        features->pwtt > 0.5f
    );
}

void calibrate_blood_pressure(float measured_systolic, float measured_diastolic)
{
    // 参数有效性检查
    if (measured_systolic < 80.0f || measured_systolic > 200.0f ||
        measured_diastolic < 40.0f || measured_diastolic > 120.0f) {
        printf("Invalid calibration values\n");
        return;
    }
    
    // 计算动态调整因子（基于血压正常波动范围）
    const float sys_range = 200.0f - 80.0f;    // 120 mmHg范围
    const float dia_range = 120.0f - 40.0f;    // 80 mmHg范围
    
    // 计算系数调整量（带归一化处理）
    float sys_adjust = ((measured_systolic - base_systolic) / sys_range) * 0.5f;
    float dia_adjust = ((measured_diastolic - base_diastolic) / dia_range) * 0.5f;
    
    // 应用调整（限制调整幅度在±50%内）
    systolic_coeff = fmaxf(0.5f, fminf(2.0f, systolic_coeff + sys_adjust));
    diastolic_coeff = fmaxf(0.5f, fminf(2.0f, diastolic_coeff + dia_adjust));
    
    // 更新基准值（使用加权平均保持稳定性）
    base_systolic = 0.8f * base_systolic + 0.2f * measured_systolic;
    base_diastolic = 0.8f * base_diastolic + 0.2f * measured_diastolic;
    
    // // 打印校准结果
    // printf("[Calibration Report]\n");
    // printf("Measured Values: %.1f/%.1f mmHg\n", measured_systolic, measured_diastolic);
    // printf("New Coefficients: S=%.3f, D=%.3f\n", systolic_coeff, diastolic_coeff);
    // printf("Updated Baseline: S=%.1f, D=%.1f\n\n", base_systolic, base_diastolic);
}

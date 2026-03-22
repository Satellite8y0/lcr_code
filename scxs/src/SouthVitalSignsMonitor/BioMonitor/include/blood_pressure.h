#ifndef BLOOD_PRESSURE_H
#define BLOOD_PRESSURE_H

#include <stdint.h>

// 血压估算结构体
typedef struct {
    int32_t systolic;    // 收缩压 (mmHg)
    int32_t diastolic;   // 舒张压 (mmHg)
    uint8_t valid;       // 数据有效标志
} BloodPressure_t;

// 波形特征结构体
typedef struct {
    float rise_time;     // 上升时间 (ms)
    float peak_amp;      // 峰值幅度 
    float area_ratio;    // 波形面积比
    float pwtt;          // 脉搏波传输时间
} WaveFeatures_t;

// 函数原型
void extract_wave_features(const uint32_t *ppg_buffer, uint16_t len, WaveFeatures_t *features);
void calculate_blood_pressure(const WaveFeatures_t *features, BloodPressure_t *result);
void calibrate_blood_pressure(float measured_systolic, float measured_diastolic);

#endif // BLOOD_PRESSURE_H

#include "heart_rate.h"
#include <stdint.h>
#include <stdbool.h>

// Variables for heart rate detection
int16_t IR_AC_Max = 20;
int16_t IR_AC_Min = -20;
int16_t IR_AC_Signal_Current = 0;
int16_t IR_AC_Signal_Previous;
int16_t IR_AC_Signal_min = 0;
int16_t IR_AC_Signal_max = 0;
int16_t IR_Average_Estimated;
int16_t positiveEdge = 0;
int16_t negativeEdge = 0;
int32_t ir_avg_reg = 0;
int16_t cbuf[32];
uint8_t offset = 0;

// FIR filter coefficients
static const uint16_t FIRCoeffs[12] = {172, 321, 579, 927, 1360, 1858, 2390, 2916, 3391, 3768, 4012, 4096};

bool check_for_beat(int32_t sample) {
    bool beat_detected = false;
    IR_AC_Signal_Previous = IR_AC_Signal_Current;
    
    // Process next data sample
    IR_Average_Estimated = average_dc_estimator(&ir_avg_reg, sample);
    IR_AC_Signal_Current = low_pass_fir_filter(sample - IR_Average_Estimated);
    
    // Detect positive zero crossing (rising edge)
    if ((IR_AC_Signal_Previous < 0) && (IR_AC_Signal_Current >= 0)) {
        IR_AC_Max = IR_AC_Signal_max;
        IR_AC_Min = IR_AC_Signal_min;
        
        positiveEdge = 1;
        negativeEdge = 0;
        IR_AC_Signal_max = 0;
        
        if ((IR_AC_Max - IR_AC_Min) > 20 && (IR_AC_Max - IR_AC_Min) < 1000) {
            beat_detected = true;
        }
    }
    
    // Detect negative zero crossing (falling edge)
    if ((IR_AC_Signal_Previous > 0) && (IR_AC_Signal_Current <= 0)) {
        positiveEdge = 0;
        negativeEdge = 1;
        IR_AC_Signal_min = 0;
    }
    
    // Find maximum value in positive cycle
    if (positiveEdge && (IR_AC_Signal_Current > IR_AC_Signal_Previous)) {
        IR_AC_Signal_max = IR_AC_Signal_Current;
    }
    
    // Find minimum value in negative cycle
    if (negativeEdge && (IR_AC_Signal_Current < IR_AC_Signal_Previous)) {
        IR_AC_Signal_min = IR_AC_Signal_Current;
    }
    
    return beat_detected;
}

int16_t average_dc_estimator(int32_t *p, uint16_t x) {
    *p += ((((int32_t)x << 15) - *p) >> 4);
    return (int16_t)(*p >> 15);
}

int16_t low_pass_fir_filter(int16_t din) {
    cbuf[offset] = din;
    
    int32_t z = mul16(FIRCoeffs[11], cbuf[(offset - 11) & 0x1F]);
    
    for (uint8_t i = 0; i < 11; i++) {
        z += mul16(FIRCoeffs[i], cbuf[(offset - i) & 0x1F] + cbuf[(offset - 22 + i) & 0x1F]);
    }
    
    offset++;
    offset %= 32; // Wrap condition
    
    return (int16_t)(z >> 15);
}

int32_t mul16(int16_t x, int16_t y) {
    return (int32_t)x * (int32_t)y;
}
#ifndef SPO2_ALGORITHM_H
#define SPO2_ALGORITHM_H

#include <stdint.h>
#include <stdbool.h>

#define FREQ_S 25    // Sampling frequency
#define BUFFER_SIZE (FREQ_S * 4)
#define MA4_SIZE 4   // Moving average size

// SpO2 lookup table
extern const uint8_t uch_spo2_table[184];

// Buffer for IR and red data
extern int32_t an_x[BUFFER_SIZE]; // IR buffer
extern int32_t an_y[BUFFER_SIZE]; // Red buffer

// Function prototypes
void maxim_heart_rate_and_oxygen_saturation(uint32_t *pun_ir_buffer, int32_t n_ir_buffer_length, 
                                          uint32_t *pun_red_buffer, int32_t *pn_spo2, 
                                          int8_t *pch_spo2_valid, int32_t *pn_heart_rate, 
                                          int8_t *pch_hr_valid);
void maxim_find_peaks(int32_t *pn_locs, int32_t *n_npks, int32_t *pn_x, int32_t n_size, 
                     int32_t n_min_height, int32_t n_min_distance, int32_t n_max_num);
void maxim_peaks_above_min_height(int32_t *pn_locs, int32_t *n_npks, int32_t *pn_x, 
                                 int32_t n_size, int32_t n_min_height);
void maxim_remove_close_peaks(int32_t *pn_locs, int32_t *pn_npks, int32_t *pn_x, 
                             int32_t n_min_distance);
void maxim_sort_ascend(int32_t *pn_x, int32_t n_size);
void maxim_sort_indices_descend(int32_t *pn_x, int32_t *pn_indx, int32_t n_size);

#endif // SPO2_ALGORITHM_H
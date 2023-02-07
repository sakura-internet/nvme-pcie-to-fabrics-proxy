#ifndef __COMMON_H__
#define __COMMON_H__

#include <gmp.h>
#define __gmp_const const
#include <string>
#include <math.h>
#include <hls_stream.h>
#include <ap_int.h>
#include <stdint.h>
#include <string.h>
#include <ap_shift_reg.h>
#include "ap_axi_sdata.h"

//template<int D,int U,int TI,int TD>
//struct ap_axiu{
//  ap_uint<D> data;
//  ap_uint<D/8> keep;
//  ap_uint<D/8> strb;
//  ap_uint<U> user;
//  ap_uint<1> last;
//  ap_uint<TI> id;
//  ap_uint<TD> dest;
//};
typedef ap_axiu<64, 0, 0, 0> L8_AXIU_PKT;

typedef ap_uint<8>  UINT8;
typedef ap_uint<16> UINT16;
typedef ap_uint<24> UINT24;
typedef ap_uint<32> UINT32;
typedef ap_uint<48> UINT48;
typedef ap_uint<64> UINT64;

#endif // __COMMON_H__

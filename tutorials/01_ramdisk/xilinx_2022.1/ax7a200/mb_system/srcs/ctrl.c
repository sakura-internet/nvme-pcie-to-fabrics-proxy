#include <stdio.h>
#include <unistd.h>
#include "xparameters.h"
#include "platform.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "xil_io.h"
#include "xtmrctr.h"
#include "xintc.h"
#include "mb_interface.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// disable __DEBUG_PRINT__ to run stand-alone because xil_printf block running without debug cable
//#define __DEBUG_PRINT__
#ifdef __DEBUG_PRINT__
	#define DEBUG_PRINT(...) xil_printf(__VA_ARGS__)
#else
	#define DEBUG_PRINT(...)
#endif

// switching PCIE busmaster accessing method
#define __PCIE_BUSMASTER_7SERIES__
//#define __PCIE_BUSMASTER_ULTRASCALE__

// aliasing BAR0 MMIO Memory and SDRAM backing store
#define BAR0_ADDR XPAR_BAR0_MB_BRAMC_S_AXI_BASEADDR
#define SDRAM_ADDR XPAR_SDRAM_MIG_BASEADDR // for other
//#define SDRAM_ADDR 0x100000000 // for au50 (AXI buses with multiple aperture are not listed properly on xparameters.h)

// PCIE busmaster access port offset in extended range
// note : extended range peripherals are not automatically listed on xparameters.h
#define XPAREXT_PCIE_BUSMASTER_AXIBAR_0  0x0000000400000000ULL // for 7-series
//#define XPAREXT_PCIE_BUSMASTER_AXIBAR_0  0x0001000000000000ULL // for ultrascale

// ramdisk size params based on size of SDRAM on board
#define LBA_SIZE 512
#define DISK_SIZE (1024*1024*1024)
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// NVMe BAR0 register settings
// (based on 3.1 Register definition)

// ultrascale AXI Bridge for PCIe IRQBLOCK registers offset ([31:28] remapped into [19:16])
#define PCIE_REG_IRQBLOCK_IDENT     0x00012000U
#define PCIE_REG_IRQBLOCK_EN_RW     0x00012004U
#define PCIE_REG_IRQBLOCK_EN_W1S    0x00012008U
#define PCIE_REG_IRQBLOCK_EN_W1C    0x0001200cU
#define PCIE_REG_IRQBLOCK_REQ       0x00012040U
#define PCIE_REG_IRQBLOCK_PENDING   0x00012048U
#define PCIE_REG_IRQBLOCK_VEC_NUM_0 0x00012080U
#define PCIE_REG_IRQBLOCK_VEC_NUM_1 0x00012084U
#define PCIE_REG_IRQBLOCK_VEC_NUM_2 0x00012088U
#define PCIE_REG_IRQBLOCK_VEC_NUM_3 0x0001208cU

// ultrascale AXI Bridge for PCIe MSI-X registers offset (([31:28] remapped into [19:16])
#define PCIE_REG_MSIX_TBL_BASEADDR  0x00018000U
#define PCIE_REG_MSIX_TBL_STRIDE    0x00000010U
#define PCIE_REG_MSIX_TBL_ADDR_LO   0x00000000U
#define PCIE_REG_MSIX_TBL_ADDR_HI   0x00000004U
#define PCIE_REG_MSIX_TBL_DATA      0x00000008U
#define PCIE_REG_MSIX_TBL_CTRL      0x0000000cU
#define PCIE_REG_MSIX_PBA           0x00018fe0U

// emulated BAR0 CAP (controller capabilities) register definition (offset 0x00 - 0x07)
#define NVME_CAP_LO_MQES            0x00003fffU    // [15:0] Maximum Queue Entries : 16'd16384
#define NVME_CAP_LO_CQR             0x00000001U    // [16] Contiguous Queues Required : 1'b1
#define NVME_CAP_LO_AMS             0x00000000U    // [18:17] Arbitration Mechanism Supported : 2'b00 (Round Robin)
#define NVME_CAP_LO_TO              0x00000014U    // [31:24] Timeout : 8'd20 (10 sec.)
#define NVME_CAP_HI_DSTRD           0x00000000U    // [3:0] Doorbell Stride : 4'd0 (4 byte)
#define NVME_CAP_HI_NSSRS           0x00000000U    // [4] NVM Subsystem Reset : 1'b0 (not supported)
#define NVME_CAP_HI_CSS             0x00000001U    // [12:5] Command Sets Supported : 8'b00000001 (NVM Command Set)
#define NVME_CAP_HI_BPS             0x00000000U    // [13] Boot Partition Support : 1'b0 (not supported)
#define NVME_CAP_HI_MPSMIN          0x00000000U    // [19:16] Memory Page Size Minimum : 4'd0 (4kB)
#define NVME_CAP_HI_MPSMAX          0x00000000U    // [23:20] Memory Page Size Maximum : 4'd0 (4kB)
#define NVME_CAP_HI_PMRS            0x00000000U    // [24] Persistent Memory Region Supported : 1'b0 (not supported)
#define NVME_CAP_HI_CMBS            0x00000000U    // [25] Controller Memory Buffer Supported : 1'b0 (not supported)
#define NVME_CAP_LO_MQES_MASK       0x0000FFFFU
#define NVME_CAP_LO_MQES_SHIFT      0
#define NVME_CAP_LO_CQR_MASK        0x00010000U
#define NVME_CAP_LO_CQR_SHIFT       16
#define NVME_CAP_LO_AMS_MASK        0x00060000U
#define NVME_CAP_LO_AMS_SHIFT       17
#define NVME_CAP_LO_TO_MASK         0xFF000000U
#define NVME_CAP_LO_TO_SHIFT        24
#define NVME_CAP_HI_DSTRD_MASK      0x0000000FU
#define NVME_CAP_HI_DSTRD_SHIFT     0
#define NVME_CAP_HI_NSSRS_MASK      0x00000010U
#define NVME_CAP_HI_NSSRS_SHIFT     4
#define NVME_CAP_HI_CSS_MASK        0x00001FE0U
#define NVME_CAP_HI_CSS_SHIFT       5
#define NVME_CAP_HI_BPS_MASK        0x00002000U
#define NVME_CAP_HI_BPS_SHIFT       13
#define NVME_CAP_HI_MPSMIN_MASK     0x000F0000U
#define NVME_CAP_HI_MPSMIN_SHIFT    16
#define NVME_CAP_HI_MPSMAX_MASK     0x00F00000U
#define NVME_CAP_HI_MPSMAX_SHIFT    20
#define NVME_CAP_HI_PMRS_MASK       0x01000000U
#define NVME_CAP_HI_PMRS_SHIFT      24
#define NVME_CAP_HI_CMBS_MASK       0x02000000U
#define NVME_CAP_HI_CMBS_SHIFT      25
#define NVME_CAP_LOWORD \
( NVME_CAP_LO_TO << NVME_CAP_LO_TO_SHIFT \
| NVME_CAP_LO_AMS << NVME_CAP_LO_AMS_SHIFT \
| NVME_CAP_LO_CQR << NVME_CAP_LO_CQR_SHIFT \
| NVME_CAP_LO_MQES << NVME_CAP_LO_MQES_SHIFT)
#define NVME_CAP_HIWORD \
( NVME_CAP_HI_CMBS << NVME_CAP_HI_CMBS_SHIFT \
| NVME_CAP_HI_PMRS << NVME_CAP_HI_PMRS_SHIFT \
| NVME_CAP_HI_MPSMAX << NVME_CAP_HI_MPSMAX_SHIFT \
| NVME_CAP_HI_MPSMIN << NVME_CAP_HI_MPSMIN_SHIFT \
| NVME_CAP_HI_BPS << NVME_CAP_HI_BPS_SHIFT \
| NVME_CAP_HI_NSSRS << NVME_CAP_HI_NSSRS_SHIFT \
| NVME_CAP_HI_DSTRD << NVME_CAP_HI_DSTRD_SHIFT)
#define NVME_CAP_LOWORD_OFFSET      0x00000000U
#define NVME_CAP_HIWORD_OFFSET      0x00000004U

// emulated BAR0 VS (version) register definition (offset 0x08 - 0x0b)
#define NVME_VS                     0x00010300U
#define NVME_VS_OFFSET              0x00000008U

// emulated BAR0 CC (controller configuration) register definition (offset 0x14 - 0x17)
#define NVME_CC_EN_MASK             0x00000001U
#define NVME_CC_EN_SHIFT            0
#define NVME_CC_CSS_MASK            0x00000070U
#define NVME_CC_CSS_SHIFT           4
#define NVME_CC_MPS_MASK            0x00000780U
#define NVME_CC_MPS_SHIFT           7
#define NVME_CC_AMS_MASK            0x00003800U
#define NVME_CC_AMS_SHIFT           11
#define NVME_CC_SHN_MASK            0x0000c000U
#define NVME_CC_SHN_SHIFT           14
#define NVME_CC_IOSQES_MASK         0x000f0000U
#define NVME_CC_IOSQES_SHIFT        16
#define NVME_CC_IOCQES_MASK         0x00f00000U
#define NVME_CC_IOCQES_SHIFT        20
#define NVME_CC_OFFSET              0x00000014U

// emulated BAR0 CSTS (controller status) register definition (offset 0x1c - 0x1f)
#define NVME_CSTS_RDY_MASK          0x00000001U
#define NVME_CSTS_RDY_SHIFT         0
#define NVME_CSTS_CFS_MASK          0x00000002U
#define NVME_CSTS_CFS_SHIFT         1
#define NVME_CSTS_SHST_MASK         0x0000000cU
#define NVME_CSTS_SHST_SHIFT        2
#define NVME_CSTS_NSSRO_MASK        0x00000010U
#define NVME_CSTS_NSSRO_SHIFT       4
#define NVME_CSTS_PP_MASK           0x00000020U
#define NVME_CSTS_PP_SHIFT          5
#define NVME_CSTS_OFFSET            0x0000001cU

// emulated BAR0 AQA (admin queue attributes) register definition (offset 0x24 - 0x27)
#define NVME_AQA_OFFSET             0x00000024U
#define NVME_AQA_ASQS_MASK          0x00000FFFU
#define NVME_AQA_ASQS_SHIFT         0
#define NVME_AQA_ACQS_MASK          0x0FFF0000U
#define NVME_AQA_ACQS_SHIFT         16

// emulated BAR0 ASQ (admin submission queue base address) register definition (offset 0x28 - 0x2f)
#define NVME_ASQ_LO_OFFSET          0x00000028U
#define NVME_ASQ_HI_OFFSET          0x0000002cU

// emulated BAR0 ACQ (admin completion queue base address) register definition (offset 0x30 - 0x37)
#define NVME_ACQ_LO_OFFSET          0x00000030U
#define NVME_ACQ_HI_OFFSET          0x00000034U

// emulated BAR0 SQTDBL/CQHDBL register definition (offset 0x1000 and 0x0008 stride for each pair)
#define NVME_SQTDBL_BASE            0x00001000U
#define NVME_CQHDBL_BASE            0x00001004U
#define NVME_SQTDBL_SQT_MASK        0x0000FFFFU
#define NVME_SQTDBL_SQT_SHIFT       0
#define NVME_CQHDBL_CQH_MASK        0x0000FFFFU
#define NVME_CQHDBL_CQH_SHIFT       0

////////////////////////////////////////////////////////////////////////////////
// emulated NVMe parameters
#define BAR0_SIZE                   16384

#define NVME_NSQ_QID_MAX            2
#define NVME_NCQ_QID_MAX            2

// NVMe CQ Field Definition
// (based on 4.6 Completion Queue Entry)
#define CQ_ENTRY_DW2_SQID_MASK      0xFFFF0000U
#define CQ_ENTRY_DW2_SQID_SHIFT     16
#define CQ_ENTRY_DW2_SQHD_MASK      0x0000FFFFU
#define CQ_ENTRY_DW2_SQHD_SHIFT     0
#define CQ_ENTRY_DW3_DNR_MASK       0x80000000U
#define CQ_ENTRY_DW3_DNR_SHIFT      31
#define CQ_ENTRY_DW3_M_MASK         0x40000000U
#define CQ_ENTRY_DW3_M_SHIFT        30
#define CQ_ENTRY_DW3_CRD_MASK       0x30000000U
#define CQ_ENTRY_DW3_CRD_SHIFT      28
#define CQ_ENTRY_DW3_SCT_MASK       0x0E000000U
#define CQ_ENTRY_DW3_SCT_SHIFT      25
#define CQ_ENTRY_DW3_SC_MASK        0x01FE0000U
#define CQ_ENTRY_DW3_SC_SHIFT       17
#define CQ_ENTRY_DW3_P_MASK         0x00010000U
#define CQ_ENTRY_DW3_P_SHIFT        16
#define CQ_ENTRY_DW3_CID_MASK       0x0000FFFFU
#define CQ_ENTRY_DW3_CID_SHIFT      0

#define CQ_ENTRY_DW3_SCT_GENERIC               0x00000000U
#define CQ_ENTRY_DW3_SCT_COMSPEC               0x01000000U
#define CQ_ENTRY_DW3_SC_GENERIC_SUCCESS        0x00000000U
#define CQ_ENTRY_DW3_SC_GENERIC_INVALID_OPCODE 0x00020000U
#define CQ_ENTRY_DW3_SC_COMSPEC_INVALID_FORMAT 0x00140000U
#define CQ_ENTRY_DW3_SC_DNR                    0x80000000U

// NVMe admin command opcode
// (based on 5. Admin Command Set)
enum NVME_ADMIN_OP {
	NVME_ADMIN_OP_DELETE_IO_SQ    = 0x00,
	NVME_ADMIN_OP_CREATE_IO_SQ    = 0x01,
	NVME_ADMIN_OP_GET_LOG_PAGE    = 0x02,
	NVME_ADMIN_OP_DELETE_IO_CQ    = 0x04,
	NVME_ADMIN_OP_CREATE_IO_CQ    = 0x05,
	NVME_ADMIN_OP_IDENTIFY        = 0x06,
	NVME_ADMIN_OP_ABORT_CMD       = 0x08,
	NVME_ADMIN_OP_SET_FEATURES    = 0x09,
	NVME_ADMIN_OP_GET_FEATURES    = 0x0a,
	NVME_ADMIN_OP_ASYNC_EVENT_REQ = 0x0c,
	NVME_ADMIN_OP_NS_ATTACH       = 0x15,
	NVME_ADMIN_OP_KEEP_ALIVE      = 0x18,
};

// IO command set opcode
// (based on 6. NVM Command Set)
enum NVME_IO_OP {
	NVME_IO_OP_FLUSH              = 0x00,
	NVME_IO_OP_WRITE              = 0x01,
	NVME_IO_OP_READ               = 0x02,
};

// NVMe admin identify command CNS (controller or namespace)
// (based on 5.15 Identify command)
enum NVME_ADMIN_OP_IDENTIFY_CNS {
	NVME_ADMIN_OP_IDENTIFY_CNS_NS                     = 0x00,
	NVME_ADMIN_OP_IDENTIFY_CNS_CTRL                   = 0x01,
	NVME_ADMIN_OP_IDENTIFY_CNS_ACTIVE_NS_LIST         = 0x02,
	NVME_ADMIN_OP_IDENTIFY_CNS_NS_DESC_LIST           = 0x03,
	NVME_ADMIN_OP_IDENTIFY_CNS_ALLOCATED_NS_LIST      = 0x10,
	NVME_ADMIN_OP_IDENTIFY_CNS_CTRL_LIST              = 0x13,
};

// NVMe admin set feature command FID
// (based on 5.21 Set Features Command)
enum NVME_ADMIN_OP_SET_FEATURES_FID{
	NVME_ADMIN_OP_SET_FEATURES_FID_NUM_QUEUES         = 0x07,
	NVME_ADMIN_OP_SET_FEATURES_FID_ASYNC_EVENT_CONFIG = 0x0b,
	NVME_ADMIN_OP_SET_FEATURES_FID_KEEP_ALIVE_TIMER   = 0x0f,
	NVME_ADMIN_OP_SET_FEATURES_FID_HOST_ID            = 0x81,
};

// AXI firewall register struct
typedef struct {
	u32 mi_side_fault_status;
	u32 mi_side_fault_control;
	u32 mi_side_unblock_control;
	u32 reserved0;
	u32 ip_version;
	u32 soft_pause;
	u32 reserved1[(0x30 - 0x18)/4];
	u32 max_continuous_rtransfers_waits;
	u32 max_write_to_bvalid_waits;
	u32 max_arready_waits;
	u32 max_awready_waits;
	u32 max_wready_waits;
	u32 reserved2[(0x100 - 0x44)/4];
	u32 si_side_fault_status;
	u32 si_side_soft_fault_control;
	u32 si_side_unblock_control;
} PROTOCOL_FIREWALL_REGS;


////////////////////////////////////////////////////////////////////////////////
// globals
////////////////////////////////////////////////////////////////////////////////

// AXI firewall register struct instance
static volatile PROTOCOL_FIREWALL_REGS* const pcie_fw_in_regs = (volatile PROTOCOL_FIREWALL_REGS*)XPAR_PCIE_SYSTEM_FW_IN_BASEADDR;
static volatile PROTOCOL_FIREWALL_REGS* const pcie_fw_out_regs = (volatile PROTOCOL_FIREWALL_REGS*)XPAR_PCIE_SYSTEM_FW_OUT_BASEADDR;

// GPIO LED peripherals
XGpio         gpio_led;
XGpio_Config  gpio_led_cfg;
unsigned char gpio_led_stat;

// timer interrupt peripherals
XIntc         intc;
XTmrCtr       tmr;

// some portion of decoded BAR register will be shared globally in this program
u32 nvme_csts;                 // controller status
u8  nvme_csts_rdy;             // CSTS ready
u8  nvme_csts_cfs;             // CSTS controller fatal status
u8  nvme_csts_shst;            // CSTS shutdown status
u8  nvme_csts_nssro;           // CSTS NVM subsystem reset occurred
u8  nvme_csts_pp;              // CSTS processing paused

u32 nvme_cc;                   // controller configuration
u8  nvme_cc_en;                // CC enable
u8  nvme_cc_css;               // CC I/O command set selected
u8  nvme_cc_mps;               // CC memory page size
u8  nvme_cc_ams;               // CC arbitration mechanism selected
u8  nvme_cc_shn;               // CC shutdown notification
u8  nvme_cc_iosqes;            // CC I/O submission queue entry size
u8  nvme_cc_iocqes;            // CC I/O completion queue entry size

u16 nvme_io_nsqa;              // number of I/O submission queue allocated (0-based, 0 means 1)
u16 nvme_io_ncqa;              // number of I/O completion queue allocated (0-based, 0 means 1)

// Submission / Completion queue registers
u8  nvme_sqen[NVME_NSQ_QID_MAX+1];   // SQ slot in-use flag (1 for in-use, 0 for vacant)
u16 nvme_sqmax[NVME_NSQ_QID_MAX+1];  // SQ queue max idx (size - 1) list
u64 nvme_sqaddr[NVME_NSQ_QID_MAX+1]; // SQ queue base address list
u16 nvme_sqtdbl[NVME_NSQ_QID_MAX+1]; // submission queue tail doorbell
u16 nvme_sqhdbl[NVME_NSQ_QID_MAX+1]; // (internal) submission queue head doorbell
u16 nvme_sq2cq[NVME_NSQ_QID_MAX+1];  // SQ slot to CQ qid conversion table

u8  nvme_cqen[NVME_NCQ_QID_MAX+1];   // CQ slot in-use flag (1 for in-use, 0 for vacant)
u16 nvme_cqmax[NVME_NCQ_QID_MAX+1];  // CQ queue max idx (size - 1) list
u64 nvme_cqaddr[NVME_NCQ_QID_MAX+1]; // CQ queue base address list
u16 nvme_cqtdbl[NVME_NCQ_QID_MAX+1]; // (internal) completion queue tail doorbell
u16 nvme_cqhdbl[NVME_NCQ_QID_MAX+1]; // completion queue head doorbell
u16 nvme_intv[NVME_NCQ_QID_MAX+1];   // CQ interrupt vector allocation list
u16 nvme_inten[NVME_NCQ_QID_MAX+1];  // CQ interrupt vector enable (1 for in-use, 0 for vacant)

// some portion of decoded CQ entry is shared globally in this program
u32 sq_entry[16];                    // submission queue entry that currently under processing
u16 sq_entry_cdw0_cid;               // Command Identifier

// some portion of CQ entry is shared globally passing parameters to post_cq_entry function
u32 cq_entry[4];

// some portion of decoded identify set features stored in globals
u32 nvme_feat_aec;                   // 5.21.1.11 Asynchronous Event Configuration

// helper function for accessing extended range address (above 4GB) on Microblaze peripheral port
static inline u32 readwea(u64 addr) {
	u32 ret = 0U;
	__asm__ __volatile__ (
		"lwea\t%0,%M1,%L1\n" : "=d"(ret) : "d" (addr)
	);
	return ret;
}
static inline void writewea(u64 addr, u32 data) {
	__asm__ __volatile__ (
		"swea\t%0,%M1,%L1\n" :: "d"(data), "d" (addr)
	);
	return;
}
static inline void writebea(u64 addr, u32 data) {
	__asm__ __volatile__ (
		"sbea\t%0,%M1,%L1\n" :: "d"(data), "d" (addr)
	);
	return;
}
void memwrite_ea(u64 addr, void* buf, u32 num) {
	u8* p = (u8*)buf;
	u32 bytes_written = 0;
	u32 num_aligned = num & ~3;
	for (; bytes_written < num_aligned; bytes_written += 4, p += 4) {
		u32 word;
		word = (p[3] << 24) | (p[2] << 16) | (p[1] << 8) | p[0];
		writewea(addr + bytes_written, word);
	}
	for(; bytes_written < num; bytes_written++, p++) {
		writebea(addr + bytes_written, *p);
	}
}
void memread_ea(u64 addr, u8* buf, u32 num) {
	for (u32 i = 0; i < num; i += 4, buf += 4) {
		u32 word = readwea(addr + i);
		buf[0] = (word >>  0) & 0xff;
		buf[1] = (word >>  8) & 0xff;
		buf[2] = (word >> 16) & 0xff;
		buf[3] = (word >> 24) & 0xff;
	}
}

// helper function for PCIe busmaster access,
// supporting both native 64bit addr (Ult/Ult+ gen3 bridge) and 2 staged 32bit addr access (7-series gen2 bridge)
u32 pcie_busmaster_read32(u64 offset) {
#ifdef __PCIE_BUSMASTER_7SERIES__
	writewea((u64)XPAR_PCIE_SYSTEM_PCIE_BASEADDR + 0x208, (u32)(offset >> 32));
	writewea((u64)XPAR_PCIE_SYSTEM_PCIE_BASEADDR + 0x20c, 0x00000000U);
	return readwea(XPAREXT_PCIE_BUSMASTER_AXIBAR_0 + (offset & 0x00000000ffffffffULL));
#endif
#ifdef __PCIE_BUSMASTER_ULTRASCALE__
	return readwea(XPAREXT_PCIE_BUSMASTER_AXIBAR_0 + offset);
#endif
}
void pcie_busmaster_write32(u64 offset, u32 data) {
#ifdef __PCIE_BUSMASTER_7SERIES__
	writewea((u64)XPAR_PCIE_SYSTEM_PCIE_BASEADDR + 0x208, (u32)(offset >> 32));
	writewea((u64)XPAR_PCIE_SYSTEM_PCIE_BASEADDR + 0x20c, 0x00000000U);
	writewea(XPAREXT_PCIE_BUSMASTER_AXIBAR_0 + (offset & 0x00000000ffffffffULL), data);
#endif
#ifdef __PCIE_BUSMASTER_ULTRASCALE__
	writewea(XPAREXT_PCIE_BUSMASTER_AXIBAR_0 + offset, data);
#endif
	return;
}
void pcie_busmaster_write8(u64 offset, u8 data) {
#ifdef __PCIE_BUSMASTER_7SERIES__
	writewea((u64)XPAR_PCIE_SYSTEM_PCIE_BASEADDR + 0x208, (u32)(offset >> 32));
	writewea((u64)XPAR_PCIE_SYSTEM_PCIE_BASEADDR + 0x20c, 0x00000000U);
	writebea(XPAREXT_PCIE_BUSMASTER_AXIBAR_0 + (offset & 0x00000000ffffffffULL), (u32)data);
#endif
#ifdef __PCIE_BUSMASTER_ULTRASCALE__
	writebea(XPAREXT_PCIE_BUSMASTER_AXIBAR_0 + offset, data);
#endif
	return;
}

void pcie_busmaster_memwrite(u64 offset, void* buf, u32 num) {
#ifdef __PCIE_BUSMASTER_7SERIES__
	u32 idx = 0;
	u32 hiword;
	u8* cbuf = (u8*)buf;
	for (; idx < (num & 0xfffffffcU); idx += 4) {
		if (idx == 0 || hiword != (u32)(offset >> 32)) {
			hiword = (u32)(offset >> 32);
			writewea((u64)XPAR_PCIE_SYSTEM_PCIE_BASEADDR + 0x208, hiword);
			writewea((u64)XPAR_PCIE_SYSTEM_PCIE_BASEADDR + 0x20c, 0x00000000U);
		}
		u32 word = ((u32)(cbuf[3]) << 24) | ((u32)(cbuf[2]) << 16) | ((u32)(cbuf[1]) << 8) | (u32)(cbuf[0]);
		writewea(XPAREXT_PCIE_BUSMASTER_AXIBAR_0 + (offset & 0x00000000ffffffffULL), word);
		offset += 4;
		cbuf += 4;
	}
	for (; idx < num; idx ++) {
		if (idx == 0 || hiword != (u32)(offset >> 32)) {
			hiword = (u32)(offset >> 32);
			writewea((u64)XPAR_PCIE_SYSTEM_PCIE_BASEADDR + 0x208, hiword);
			writewea((u64)XPAR_PCIE_SYSTEM_PCIE_BASEADDR + 0x20c, 0x00000000U);
		}
		writebea(XPAREXT_PCIE_BUSMASTER_AXIBAR_0 + (offset & 0x00000000ffffffffULL), (*cbuf));
		offset ++;
		cbuf ++;
	}
#endif
#ifdef __PCIE_BUSMASTER_ULTRASCALE__
	u32 idx = 0;
	u8* cbuf = (u8*)buf;
	for (; idx < (num & 0xfffffffcU); idx += 4) {
		u32 word = ((u32)(cbuf[3]) << 24) | ((u32)(cbuf[2]) << 16) | ((u32)(cbuf[1]) << 8) | (u32)(cbuf[0]);
		writewea(XPAREXT_PCIE_BUSMASTER_AXIBAR_0 + offset, word);
		offset += 4;
		cbuf += 4;
	}
	for (; idx < num; idx ++) {
		writebea(XPAREXT_PCIE_BUSMASTER_AXIBAR_0 + offset, (*cbuf));
		offset ++;
		cbuf ++;
	}
#endif
}
void pcie_busmaster_memread(u64 offset, u8* buf, u32 num) {
#ifdef __PCIE_BUSMASTER_7SERIES__
	u32 hiword;
	for (u32 i = 0; i < num; i += 4) {
		if (i == 0 || hiword != (u32)(offset >> 32)) {
			hiword = (u32)(offset >> 32);
			writewea((u64)XPAR_PCIE_SYSTEM_PCIE_BASEADDR + 0x208, hiword);
			writewea((u64)XPAR_PCIE_SYSTEM_PCIE_BASEADDR + 0x20c, 0x00000000U);
		}
		u32 word = readwea(XPAREXT_PCIE_BUSMASTER_AXIBAR_0 + (offset & 0x00000000ffffffffULL));
		for (u32 j = 0; (j < 4) && (i + j < num); j ++) {
			buf[j] = word & 0xff;
			word = (word >> 8);
		}
		offset += 4;
		buf += 4;
	}
#endif
#ifdef __PCIE_BUSMASTER_ULTRASCALE__
	for (u32 i = 0; i < num; i += 4) {
		u32 word = readwea(XPAREXT_PCIE_BUSMASTER_AXIBAR_0 + offset);
		for (u32 j = 0; (j < 4) && (i + j < num); j ++) {
			buf[j] = word & 0xff;
			word = (word >> 8);
		}
		offset += 4;
		buf += 4;
	}
#endif
}

// example timer function generate heartbeat on LED
void timer_handler()
{
	// toggle LED
	gpio_led_stat = ~gpio_led_stat;
	XGpio_DiscreteWrite(&gpio_led, 1, gpio_led_stat);

	// clear interrupt
	volatile u32 csr;
	csr = XTmrCtr_GetControlStatusReg(XPAR_MB_SYSTEM_TIMER_BASEADDR, 0);
	XTmrCtr_SetControlStatusReg(XPAR_MB_SYSTEM_TIMER_BASEADDR, 0, csr);
}

s32 post_cq_entry(u16 qid, u16 status_code)
{
	// Completion Queue Entry
	//    3                   2                   1                   0
	//  1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
	// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	// |                       Command Specific                        |
	// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	// |                           Reserved                            |
	// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	// |         SQ Identifier         |        SQ Head Pointer        |
	// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	// |        Status Field         |P|      Command Identifier       |
	// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

	u16 cq_entry_dw2_sqid;          // [31:16] SQ Identifier
	u16 cq_entry_dw2_sqhd;          // [15: 0] SQ Head Pointer
	u8  cq_entry_dw3_dnr;           //    [31] Do Not Retry
	u8  cq_entry_dw3_m;             //    [30] More
	u8  cq_entry_dw3_crd;           // [29:28] Command Retry Delay
	u8  cq_entry_dw3_sct;           // [27:25] Status Code Type
	u8  cq_entry_dw3_sc;            // [24:17] Status Code
	u8  cq_entry_dw3_p;             //    [16] Phase tag
	u16 cq_entry_dw3_cid;           // [15: 0] Command Identifier

	// invert phase tag based on current CQ buffer read out
	u64 dw3_offset = (u64)(nvme_cqaddr[qid]) + (((u64)nvme_cqtdbl[qid]) << nvme_cc_iocqes) + 12;
	cq_entry_dw3_p = (u8)((pcie_busmaster_read32(dw3_offset) & CQ_ENTRY_DW3_P_MASK) >> CQ_ENTRY_DW3_P_SHIFT);
	cq_entry_dw3_p = (cq_entry_dw3_p) ? 0x00 : 0x01;

	// prepare other CQ entry elements
	cq_entry_dw2_sqid = nvme_sq2cq[qid];
	cq_entry_dw2_sqhd = nvme_sqhdbl[qid];
	cq_entry_dw3_dnr  = 0;
	cq_entry_dw3_m    = 0;
	cq_entry_dw3_crd  = 0;
	cq_entry_dw3_sct  = 0;
	cq_entry_dw3_sc   = status_code;
	cq_entry_dw3_cid  = sq_entry_cdw0_cid;

	// pack elements into dword array
	// cq_entry[0] (command specific) assumed to be updated each admin or I/O queue dispatcher function
	cq_entry[1] = 0x00000000U;
	cq_entry[2] = 0x00000000U;
	cq_entry[2] |= (((u32)cq_entry_dw2_sqid) << CQ_ENTRY_DW2_SQID_SHIFT);
	cq_entry[2] |= (((u32)cq_entry_dw2_sqhd) << CQ_ENTRY_DW2_SQHD_SHIFT);
	cq_entry[3] = 0x00000000U;
	cq_entry[3] |= (((u32)cq_entry_dw3_dnr) << CQ_ENTRY_DW3_DNR_SHIFT);
	cq_entry[3] |= (((u32)cq_entry_dw3_m) << CQ_ENTRY_DW3_M_SHIFT);
	cq_entry[3] |= (((u32)cq_entry_dw3_crd) << CQ_ENTRY_DW3_CRD_SHIFT);
	cq_entry[3] |= (((u32)cq_entry_dw3_sct) << CQ_ENTRY_DW3_SCT_SHIFT);
	cq_entry[3] |= (((u32)cq_entry_dw3_sc) << CQ_ENTRY_DW3_SC_SHIFT);
	cq_entry[3] |= (((u32)cq_entry_dw3_p) << CQ_ENTRY_DW3_P_SHIFT);
	cq_entry[3] |= (((u32)cq_entry_dw3_cid) << CQ_ENTRY_DW3_CID_SHIFT);

	// write to extended range address
	pcie_busmaster_write32(nvme_cqaddr[qid] + (nvme_cqtdbl[qid] << nvme_cc_iocqes) +  0, cq_entry[0]);
	pcie_busmaster_write32(nvme_cqaddr[qid] + (nvme_cqtdbl[qid] << nvme_cc_iocqes) +  4, cq_entry[1]);
	pcie_busmaster_write32(nvme_cqaddr[qid] + (nvme_cqtdbl[qid] << nvme_cc_iocqes) +  8, cq_entry[2]);
	pcie_busmaster_write32(nvme_cqaddr[qid] + (nvme_cqtdbl[qid] << nvme_cc_iocqes) + 12, cq_entry[3]);

	// increment CQ tail doorbell with roll-over consideration
	if (nvme_cqtdbl[qid] == nvme_cqmax[qid]) {
		nvme_cqtdbl[qid] = 0;
	} else {
		nvme_cqtdbl[qid] += 1;
	}

	// emit interrupt
	if (nvme_inten[qid]) {
#ifdef __PCIE_BUSMASTER_7SERIES__
		writewea((u64)XPAR_PCIE_SYSTEM_INTC_BASEADDR, nvme_intv[qid]);
#endif
#ifdef __PCIE_BUSMASTER_ULTRASCALE__
		u32 usr_req_irq = (0x00000001 << nvme_intv[qid]);
		writewea((u64)XPAR_PCIE_SYSTEM_INTC_BASEADDR, usr_req_irq);
#endif
		DEBUG_PRINT("post_cq_entry : cdw0 = 0x%08x with irq issued\r\n", cq_entry[0]);
	} else {
		DEBUG_PRINT("post_cq_entry : cdw0 = 0x%08x with irq skipped\r\n", cq_entry[0]);
	}

	return CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
}

s32 dispatch_admin_queue_async_event(){
	return CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
}

s32 dispatch_admin_queue_get_features(){
	return CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
}

static uint8_t local_buffer[4096];

s32 dispatch_admin_queue_identify_namespace() {
	DEBUG_PRINT("dispatch_admin_queue_identify_controller : create reply struct for NS information\r\n");

	u32 prp1_idx = 0;
	u64 num_ull = 0;
	u32 num_ul = 0;
	memset(local_buffer, 0, 4096);
	while (prp1_idx < 4096) {
		switch (prp1_idx) {
			// register definition based on "5.15.2 Identify Namespace data structure (CNS 01h)"
			case 0 :
				// Namespace Size (NSZE)
				num_ull = DISK_SIZE / LBA_SIZE;
				memcpy(local_buffer + prp1_idx, (u8*)(&num_ull), 8);
				prp1_idx += 8;
				break;
			case 8 :
				// Namespace Capacity (NCAP)
				num_ull = DISK_SIZE / LBA_SIZE;
				memcpy(local_buffer + prp1_idx, (u8*)(&num_ull), 8);
				prp1_idx += 8;
				break;
			case 16 :
				// Namespace Capacity (NUSE)
				num_ull = DISK_SIZE / LBA_SIZE;
				memcpy(local_buffer + prp1_idx, (u8*)(&num_ull), 8);
				prp1_idx += 8;
				break;
			case 24 :
				// Namespace Features (NSFEAT)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 25 :
				// Number of LBA Formats (NLBAF)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 26 :
				// Formatted LBA Size (FLBAS)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 27 :
				// Metadata Capability (MC)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 28 :
				// End-to-end Data Protection Capabilities (DPC)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 29 :
				// End-to-end Data Protection Type Settings (DPS)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 30 :
				// Namespace Multi-path I/O and Namespace Shareing Capabilities (NMIC)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 31 :
				// Reservation Capabilities (RESCAP)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 32 :
				// Format Progress Indicator (FPI)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 33 :
				// Deallocate Logical Block Features (DLFEAT)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 34 :
				// Namespace Atomic Write Unit Normal (NAWUN)
				memset(local_buffer + prp1_idx, 0x00, 2);
				prp1_idx += 2;
				break;
			case 36 :
				// Namespace Atomic Write Unit Power Fail (NAWUPF)
				memset(local_buffer + prp1_idx, 0x00, 2);
				prp1_idx += 2;
				break;
			case 38 :
				// Namespace Atomic Compare & Write Unit (NACWU)
				memset(local_buffer + prp1_idx, 0x00, 2);
				prp1_idx += 2;
				break;
			case 40 :
				// Namespace Atomic Boundary Size Normal (NABSN)
				memset(local_buffer + prp1_idx, 0x00, 2);
				prp1_idx += 2;
				break;
			case 42 :
				// Namespace Atomic Boundary Offset (NABO)
				memset(local_buffer + prp1_idx, 0x00, 2);
				prp1_idx += 2;
				break;
			case 44 :
				// Namespace Atomic Boundary Size Power Fail (NABSPF)
				memset(local_buffer + prp1_idx, 0x00, 2);
				prp1_idx += 2;
				break;
			case 46 :
				// Namespace Optimal IO Boundary (NOIOB)
				memset(local_buffer + prp1_idx, 0x00, 2);
				prp1_idx += 2;
				break;
			case 48 :
				// NVM Capacity (NVMCAP)
				num_ull = DISK_SIZE;
				memcpy(local_buffer + prp1_idx, (u8*)(&num_ull), 8);
				memset(local_buffer + prp1_idx + 8, 0x00, 8);
				prp1_idx += 16;
				break;
			case 64 :
				// Reserved
				memset(local_buffer + prp1_idx, 0x00, 40);
				prp1_idx += 40;
				break;
			case 104 :
				// Namespace Globally Unique Identifier (NGUID)
				memset(local_buffer + prp1_idx, 0x00, 16);
				prp1_idx += 16;
				break;	
			case 120 :
				// IEEE Extended Unique Identifier (EUI64)
				memset(local_buffer + prp1_idx, 0x00, 8);
				prp1_idx += 8;
				break;
			case 128 :
				//LBA Format 0 Support (LBAF0)
				num_ul = 0x00090000U;
				memcpy(local_buffer + prp1_idx, (u8*)(&num_ul), 4);
				prp1_idx += 4;
				break;
			case 132 :
				//LBA Format 1 Support (LBAF1)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 136 :
				//LBA Format 2 Support (LBAF2)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 140 :
				//LBA Format 3 Support (LBAF3)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 144 :
				//LBA Format 4 Support (LBAF4)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 148 :
				//LBA Format 5 Support (LBAF5)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 152 :
				//LBA Format 6 Support (LBAF6)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 156 :
				//LBA Format 7 Support (LBAF7)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 160 :
				//LBA Format 8 Support (LBAF8)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 164 :
				//LBA Format 9 Support (LBAF9)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 168 :
				//LBA Format 10 Support (LBAF10)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 172 :
				//LBA Format 11 Support (LBAF11)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 176 :
				//LBA Format 12 Support (LBAF12)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 180 :
				//LBA Format 13 Support (LBAF13)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 184 :
				//LBA Format 14 Support (LBAF14)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 188 :
				//LBA Format 15 Support (LBAF15)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 192 :
				// Reserved
				memset(local_buffer + prp1_idx, 0x00, 192);
				prp1_idx += 192;
				break;
			case 384 :
				// Vendor Specific
				memset(local_buffer + prp1_idx, 0x00, 3712);
				prp1_idx += 3712;
				break;
		}
	}

	// identify result will be stored into DPTR specified by sq_entry[6,7,8,9]
	// spec says "if using PRPs, this field shall not be a pointer to a PRP List as the data buffer may not cross more than one page boundary"
	// then we assume PRP2 entry (sq_entry[8, 9]) is one of below:
	//   (a) reserved
	//   (b-i)  left over data if PRP1 DPTR has PBAO (offset from 4kB alignment boundary
	u32 PRP_OFFSET_MASK = (0x00000001U << (12 + nvme_cc_mps)) - 0x00000001U;
	u64 prp1_addr = (((u64)sq_entry[7]) << 32) + ((u64)sq_entry[6]);
	u32 pbao = (u32)(prp1_addr & (u64)PRP_OFFSET_MASK);
	u32 prp1_wsize = ((0x00000001U << (12 + nvme_cc_mps)) - pbao) > 4096 ? 4096 : (0x00000001U << (12 + nvme_cc_mps)) - pbao;
	u64 prp2_addr = (((u64)sq_entry[9]) << 32) + ((u64)sq_entry[8]);
	u32 prp2_wsize = 4096 - prp1_wsize;

	DEBUG_PRINT("dispatch_admin_queue_identify_controller : store %d bytes data to PRP1 0x%08x%08x\r\n",
		prp1_wsize,
		(u32)(prp1_addr >> 32),
		(u32)(prp1_addr & 0x00000000ffffffff));
	pcie_busmaster_memwrite(prp1_addr, local_buffer, prp1_wsize);

	if (prp2_wsize != 0) {
		if (prp2_wsize != 0) {
			DEBUG_PRINT("dispatch_admin_queue_identify_controller : store %d bytes data to PRP2 0x%08x%08x\r\n",
				prp2_wsize,
				(u32)(prp2_addr >> 32),
				(u32)(prp2_addr & 0x00000000ffffffff));
			pcie_busmaster_memwrite(prp2_addr, local_buffer, prp2_wsize);
		}
		pcie_busmaster_memwrite(prp2_addr, local_buffer, prp2_wsize);
	}
	return CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
}

s32 dispatch_admin_queue_ns_active_list() {
	DEBUG_PRINT("dispatch_admin_queue_ns_active_list : list all ns with NSID over threshold\r\n");

	u32 thresh = sq_entry[1];
	if (thresh > 0xfffffffdU) {
		DEBUG_PRINT("dispatch_admin_queue_ns_active_list : NSID is greater than 0xfffffffd\r\n");
		return CQ_ENTRY_DW3_SC_COMSPEC_INVALID_FORMAT | CQ_ENTRY_DW3_SC_DNR;
	}

	u32 prp1_idx = 0;
	memset(local_buffer, 0, 4096);
	while (prp1_idx < 4096) {
		if (thresh < 1) {
			writewea(local_buffer + prp1_idx, 0x00000001U);
			thresh = 1;
			prp1_idx += 4;
		} else {
			memset(local_buffer + prp1_idx, 0x00, 4096 - prp1_idx);
			prp1_idx += (4096 - prp1_idx);
		}
	}

	// identify result will be stored into DPTR specified by sq_entry[6,7,8,9]
	// spec says "if using PRPs, this field shall not be a pointer to a PRP List as the data buffer may not cross more than one page boundary"
	// then we assume PRP2 entry (sq_entry[8, 9]) is one of below:
	//   (a) reserved
	//   (b-i)  left over data if PRP1 DPTR has PBAO (offset from 4kB alignment boundary
	u32 PRP_OFFSET_MASK = (0x00000001U << (12 + nvme_cc_mps)) - 0x00000001U;
	u64 prp1_addr = (((u64)sq_entry[7]) << 32) + ((u64)sq_entry[6]);
	u32 pbao = (u32)(prp1_addr & (u64)PRP_OFFSET_MASK);
	u32 prp1_wsize = ((0x00000001U << (12 + nvme_cc_mps)) - pbao) > 4096 ? 4096 : (0x00000001U << (12 + nvme_cc_mps)) - pbao;
	u64 prp2_addr = (((u64)sq_entry[9]) << 32) + ((u64)sq_entry[8]);
	u32 prp2_wsize = 4096 - prp1_wsize;

	DEBUG_PRINT("dispatch_admin_queue_ns_active_list : store %d bytes data to PRP1 0x%08x%08x\r\n",
		prp1_wsize,
		(u32)(prp1_addr >> 32),
		(u32)(prp1_addr & 0x00000000ffffffff));
	pcie_busmaster_memwrite(prp1_addr, local_buffer, prp1_wsize);

	if (prp2_wsize != 0) {
		DEBUG_PRINT("dispatch_admin_queue_ns_active_list : store %d bytes data to PRP2 0x%08x%08x\r\n",
			prp2_wsize,
			(u32)(prp2_addr >> 32),
			(u32)(prp2_addr & 0x00000000ffffffff));
		pcie_busmaster_memwrite(prp2_addr, local_buffer, prp2_wsize);
	}
	return CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
}

s32 dispatch_admin_queue_identify_controller()
{
	DEBUG_PRINT("dispatch_admin_queue_identify_controller : create reply struct for NVMe Identify Controllers\r\n");

	// fill out 4096b buffer with identify controller reply
	u32 prp1_idx = 0;
	u64 num_ull = 0;
	u32 num_ul = 0;
	u8 buf_sn[20] = "000000000000        ";
	u8 buf_mn[40] = "FPGA-emulated RAMDISK                   ";
	u8 buf_fr[8]  = "0000    ";
	u8 buf_nqn[256] = "nqn.2014-08.org.nvmexpress:NVMf:uuid:00000000-0000-0000-0000-000000000000";
	memset(local_buffer, 0, 4096);
	while (prp1_idx < 4096) {
		switch (prp1_idx) {
			// register definition based on "5.15.3 Identify Controller data structure (CNS 01h)"
			case 0 :
				// PCI Vendor ID (VID)
				memset(local_buffer + prp1_idx, 0xee, 1);
				memset(local_buffer + prp1_idx + 1, 0x10, 1);
				prp1_idx += 2;
				break;
			case 2 :
				// PCI Subsystem ID (SSVID)
				memset(local_buffer + prp1_idx, 0x28, 1);
				memset(local_buffer + prp1_idx + 1, 0x90, 1);
				prp1_idx += 2;
				break;
			case 4 :
				// Serial Number (SN) in ASCII
				memcpy(local_buffer + prp1_idx, buf_sn, 20);
				prp1_idx += 20;
				break;
			case 24 :
				// Model Number (MN) in ASCII
				memcpy(local_buffer + prp1_idx, buf_mn, 40);
				prp1_idx += 40;
				break;
			case 64 :
				// Firmware Revision (FR) in ASCII
				memcpy(local_buffer + prp1_idx, buf_fr, 8);
				prp1_idx += 8;
				break;
			case 72 :
				// Recommended Arbitration Burst (RAB)
				memset(local_buffer + prp1_idx, 0x01, 1);
				prp1_idx += 1;
				break;
			case 73 :
				// IEEE OUI Identifier
				memset(local_buffer + prp1_idx + 0, 0xba, 1);
				memset(local_buffer + prp1_idx + 1, 0xa3, 1);
				memset(local_buffer + prp1_idx + 2, 0x9c, 1);
				prp1_idx += 3;
				break;
			case 76 :
				// Controller Multi-Path I/O and Namespace
				// Sharing Capabilities (CMIC)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 77 :
				// Maximum Data Transfer Size (MDTS)
				memset(local_buffer + prp1_idx, 0x09, 1);
				prp1_idx += 1;
				break;
			case 78 :
				// Controller ID (CNTLID)
				memset(local_buffer + prp1_idx, 0x01, 1);
				memset(local_buffer + prp1_idx + 1, 0x00, 1);
				prp1_idx += 2;
				break;
			case 80 :
				// Version (VER)
				num_ul = 0x00010300U;
				memcpy(local_buffer + prp1_idx, (u8*)(&num_ul), 4);
				prp1_idx += 4;
				break;
			case 84 :
				// RTD3 Resume Latency (RTD3R)
				num_ul = 0x00000000U;
				memcpy(local_buffer + prp1_idx, (u8*)(&num_ul), 4);
				prp1_idx += 4;
				break;
			case 88 :
				// RTD3 Entry Latency (RTD3E)
				num_ul = 0x00000000U;
				memcpy(local_buffer + prp1_idx, (u8*)(&num_ul), 4);
				prp1_idx += 4;
				break;
			case 92 :
				// Optional Asynchronous Events Supported (OAES)
				num_ul = 0x00000000U;
				memcpy(local_buffer + prp1_idx, (u8*)(&num_ul), 4);
				prp1_idx += 4;
				break;
			case 96 :
				// Controller Attribute (CTRATT)
				num_ul = 0x00000000U;
				memcpy(local_buffer + prp1_idx, (u8*)(&num_ul), 4);
				prp1_idx += 4;
				break;
			case 100 :
				// Reserved
				memset(local_buffer + prp1_idx, 0x00, 12);
				prp1_idx += 12;
				break;
			case 112 :
				// FRU Globally Unique Identifier (FGUID)
				memset(local_buffer + prp1_idx, 0x00, 16);
				prp1_idx += 16;
				break;
			case 128 :
				// Reserved
				memset(local_buffer + prp1_idx, 0x00, 112);
				prp1_idx += 112;
				break;
			case 240 :
				// Reserved (NVMe-MI)
				memset(local_buffer + prp1_idx, 0x00, 16);
				prp1_idx += 16;
				break;
			case 256 :
				// Optional Admin Command Support (OACS)
				memset(local_buffer + prp1_idx, 0x00, 1);
				memset(local_buffer + prp1_idx + 1, 0x00, 1);
				prp1_idx += 2;
				break;
			case 258 :
				// Abort Command Limit (ACL)
				memset(local_buffer + prp1_idx, 0x03, 1);
				prp1_idx += 1;
			case 259 :
				// Asynchronous Event Request Limit (AERL)
				memset(local_buffer + prp1_idx, 0x03, 1);
				prp1_idx += 1;
			case 260 :
				// Firmware Updates (FRMW)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 261 :
				// Log Page Attributes (LPA)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 262 :
				// Error Log Page Entries (ELPE)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 263 :
				// Number of Power States Support (NPSS)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 264 :
				// Admin Vendor Specific Command Configuration (AVSCC)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 265 :
				// Autonomous Power State Transition Attributes (APSTA)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 266 :
				// Warning Composite Temperature Threshold (WCTEMP)
				memset(local_buffer + prp1_idx, 0x00, 1);
				memset(local_buffer + prp1_idx + 1, 0x00, 1);
				prp1_idx += 2;
				break;
			case 268 :
				// Critical Composite Temperature Threshold (CCTEMP)
				memset(local_buffer + prp1_idx, 0x00, 1);
				memset(local_buffer + prp1_idx + 1, 0x00, 1);
				prp1_idx += 2;
				break;
			case 270 :
				// Maximum Time for Firmware Activation (MTFA)
				memset(local_buffer + prp1_idx, 0x00, 1);
				memset(local_buffer + prp1_idx + 1, 0x00, 1);
				prp1_idx += 2;
				break;
			case 272 :
				// Host Memory Buffer Preferred Size (HMPRE)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 276 :
				// Host Memory Buffer Minimum Size (HMMIN)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 280 :
				// Total NVM Capacity (TNVMCAP)
				num_ull = DISK_SIZE;
				memcpy(local_buffer + prp1_idx, (u8*)(&num_ull), 8);
				memset(local_buffer + prp1_idx + 8, 0x00, 8);
				prp1_idx += 16;
				break;
			case 296 :
				// Unallocated NVM Capacity (UNVMCAP)
				memset(local_buffer + prp1_idx, 0x00, 16);
				prp1_idx += 16;
				break;
			case 312 :
				// Replay Protected Memory Block Support (RPMBS)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 316 :
				// Extended Device Self-test Time (EDSTT)
				memset(local_buffer + prp1_idx, 0x00, 1);
				memset(local_buffer + prp1_idx + 1, 0x00, 1);
				prp1_idx += 2;
				break;
			case 318 :
				// Device Self-test Options (DSTO)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 319 :
				// Firmware Update Granularity (FWUG)
				memset(local_buffer + prp1_idx, 0x01, 1);
				prp1_idx += 1;
				break;
			case 320 :
				// Keep Alive Support (KAS)
				memset(local_buffer + prp1_idx, 0x00, 2);
				prp1_idx += 2;
				break;
			case 322 :
				// Host Controlled Thermal Management Attributes (HCTMA)
				memset(local_buffer + prp1_idx, 0x00, 1);
				memset(local_buffer + prp1_idx + 1, 0x00, 1);
				prp1_idx += 2;
				break;
			case 324 :
				// Minimum Thermal Management Temperature (MNTMT)
				memset(local_buffer + prp1_idx, 0x00, 1);
				memset(local_buffer + prp1_idx + 1, 0x00, 1);
				prp1_idx += 2;
				break;
			case 326 :
				// Maximum Thermal Management Temperature (MXTMT)
				memset(local_buffer + prp1_idx, 0x00, 1);
				memset(local_buffer + prp1_idx + 1, 0x00, 1);
				prp1_idx += 2;
				break;
			case 328 :
				// Sanitize Capabilities (SANICAP)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 332 :
				// Reserved
				memset(local_buffer + prp1_idx, 0x00, 180);
				prp1_idx += 180;
				break;
			case 512 :
				// Submission Queue Entry Size (SQES)
				memset(local_buffer + prp1_idx, 0x66, 1);
				prp1_idx += 1;
				break;
			case 513 :
				// Completion Queue Entry Size (CQES)
				memset(local_buffer + prp1_idx, 0x44, 1);
				prp1_idx += 1;
				break;
			case 514 :
				// Maximum Outstanding Commands (MAXCMD)
				memset(local_buffer + prp1_idx, 0x00, 1);
				memset(local_buffer + prp1_idx + 1, 0x01, 1);
				prp1_idx += 2;
				break;
			case 516 :
				// Number of Namespaces (NN)
				num_ul = 0x00000001U;
				memcpy(local_buffer + prp1_idx, (u8*)(&num_ul), 4);
				prp1_idx += 4;
				break;
			case 520 :
				// Optional NVM Command Support (ONCS)
				//memset(local_buffer + prp1_idx, 0x1f, 1); // preferred
				memset(local_buffer + prp1_idx, 0x00, 1);
				memset(local_buffer + prp1_idx + 1, 0x00, 1);
				prp1_idx += 2;
				break;
			case 522 :
				// Fused Operation Support (FUSES)
				memset(local_buffer + prp1_idx, 0x00, 2);
				prp1_idx += 2;
				break;
			case 524 :
				// Format NVM Attributes (FNA)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 525 :
				// Volatile Write Cache (VWC)
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 526 :
				// Atomic Write Unit Normal (AWUN)
				memset(local_buffer + prp1_idx, 0xff, 1);
				memset(local_buffer + prp1_idx + 1, 0x00, 1);
				prp1_idx += 2;
				break;
			case 528 :
				// Atomic Write Unit Power Fail (AWUPF)
				memset(local_buffer + prp1_idx, 0x00, 2);
				prp1_idx += 2;
				break;
			case 530 :
				// NVM Vendor Specific Command Configuration (NVSCC)
				memset(local_buffer + prp1_idx, 0x01, 1);
				prp1_idx += 1;
				break;
			case 531 :
				// Reserved
				memset(local_buffer + prp1_idx, 0x00, 1);
				prp1_idx += 1;
				break;
			case 532 :
				// Atomic Compare & Write Unit (ACWU)
				memset(local_buffer + prp1_idx, 0x00, 2);
				prp1_idx += 2;
				break;
			case 534 :
				// Reserved
				memset(local_buffer + prp1_idx, 0x00, 2);
				prp1_idx += 2;
				break;
			case 536 :
				// SGL Support (SGLS)
				memset(local_buffer + prp1_idx, 0x00, 4);
				prp1_idx += 4;
				break;
			case 540 :
				// Reserved
				memset(local_buffer + prp1_idx, 0x00, 228);
				prp1_idx += 228;
				break;
			case 768 :
				// NVM Subsystem NVMe Qualified Name (SUBNQN)
				memcpy(local_buffer + prp1_idx, buf_nqn, 256);
				prp1_idx += 256;
				break;
			case 1024 :
				// Reserved
				memset(local_buffer + prp1_idx, 0x00, 768);
				prp1_idx += 768;
				break;
			case 1792 :
				// Reserved for NVMe-oF
				memset(local_buffer + prp1_idx, 0x00, 256);
				prp1_idx += 256;
				break;
			case 2048 :
				// Power State 0 Descriptor (PSD0)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2080 :
				// Power State 1 Descriptor (PSD1)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2112 :
				// Power State 2 Descriptor (PSD2)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2144 :
				// Power State 3 Descriptor (PSD3)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2176 :
				// Power State 4 Descriptor (PSD4)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2208 :
				// Power State 5 Descriptor (PSD5)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2240 :
				// Power State 6 Descriptor (PSD6)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2272 :
				// Power State 7 Descriptor (PSD7)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2304 :
				// Power State 8 Descriptor (PSD8)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2336 :
				// Power State 9 Descriptor (PSD9)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2368 :
				// Power State 10 Descriptor (PSD10)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2400 :
				// Power State 11 Descriptor (PSD11)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2432 :
				// Power State 12 Descriptor (PSD12)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2464 :
				// Power State 13 Descriptor (PSD13)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2496 :
				// Power State 14 Descriptor (PSD14)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2528 :
				// Power State 15 Descriptor (PSD15)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2560 :
				// Power State 16 Descriptor (PSD16)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2592 :
				// Power State 17 Descriptor (PSD17)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2624 :
				// Power State 18 Descriptor (PSD18)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2656 :
				// Power State 19 Descriptor (PSD19)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2688 :
				// Power State 20 Descriptor (PSD20)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2720 :
				// Power State 21 Descriptor (PSD21)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2752 :
				// Power State 22 Descriptor (PSD22)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2784 :
				// Power State 23 Descriptor (PSD23)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2816 :
				// Power State 24 Descriptor (PSD24)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2848 :
				// Power State 25 Descriptor (PSD25)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2880 :
				// Power State 26 Descriptor (PSD26)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2912 :
				// Power State 27 Descriptor (PSD27)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2944 :
				// Power State 28 Descriptor (PSD28)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 2976 :
				// Power State 29 Descriptor (PSD29)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 3008 :
				// Power State 30 Descriptor (PSD30)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 3040 :
				// Power State 31 Descriptor (PSD31)
				memset(local_buffer + prp1_idx, 0x00, 32);
				prp1_idx += 32;
				break;
			case 3072 :
				// Vendor Specific
				memset(local_buffer + prp1_idx, 0x00, 1024);
				prp1_idx += 1024;
				break;
		}
	}

	// identify result will be stored into DPTR specified by sq_entry[6,7,8,9]
	// spec says "if using PRPs, this field shall not be a pointer to a PRP List as the data buffer may not cross more than one page boundary"
	// then we assume PRP2 entry (sq_entry[8, 9]) is one of below:
	//   (a) reserved
	//   (b-i)  left over data if PRP1 DPTR has PBAO (offset from 4kB alignment boundary
	u32 PRP_OFFSET_MASK = (0x00000001U << (12 + nvme_cc_mps)) - 0x00000001U;
	u64 prp1_addr = (((u64)sq_entry[7]) << 32) + ((u64)sq_entry[6]);
	u32 pbao = (u32)(prp1_addr & (u64)PRP_OFFSET_MASK);
	u32 prp1_wsize = ((0x00000001U << (12 + nvme_cc_mps)) - pbao) > 4096 ? 4096 : (0x00000001U << (12 + nvme_cc_mps)) - pbao;
	u64 prp2_addr = (((u64)sq_entry[9]) << 32) + ((u64)sq_entry[8]);
	u32 prp2_wsize = 4096 - prp1_wsize;

	DEBUG_PRINT("dispatch_admin_queue_identify_controller : store %d bytes data to PRP1 0x%08x%08x\r\n",
		prp1_wsize,
		(u32)(prp1_addr >> 32),
		(u32)(prp1_addr & 0x00000000ffffffff));
	pcie_busmaster_memwrite(prp1_addr, local_buffer, prp1_wsize);

	if (prp2_wsize != 0) {
		DEBUG_PRINT("dispatch_admin_queue_identify_controller : store %d bytes data to PRP2 0x%08x%08x\r\n",
			prp2_wsize,
			(u32)(prp2_addr >> 32),
			(u32)(prp2_addr & 0x00000000ffffffff));
		pcie_busmaster_memwrite(prp2_addr, local_buffer, prp2_wsize);
	}
	return CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
}

s32 dispatch_admin_queue_identify()
{
	DEBUG_PRINT("dispatch_admin_queue_identify : received NVMe identify\r\n");

	u16 sq_entry_cdw10_cntid = (sq_entry[10] & 0xFFFF0000U) >> 16;
	u8 sq_entry_cdw10_cns = (sq_entry[10] & 0x000000FFU) >> 0;
	u16 sq_entry_cdw11_nvmsetid = (sq_entry[11] & 0x0000FFFF) >> 0;
	u8 sq_entry_cdw14_uuidindex = (sq_entry[14] & 0x0000007F) >> 0;
	DEBUG_PRINT("CDW10                   : %08x (cntid = %u, cns = %u)\r\n", sq_entry[10], sq_entry_cdw10_cntid, sq_entry_cdw10_cns);
	DEBUG_PRINT("CDW11                   : %08x (nvmsetid = 0x%04x)\r\n", sq_entry[11], sq_entry_cdw11_nvmsetid);
	DEBUG_PRINT("CDW14                   : %08x (uuidindex = 0x%04x)\r\n", sq_entry[11], sq_entry_cdw14_uuidindex);

	s32 ret;

	switch (sq_entry_cdw10_cns) {
		case NVME_ADMIN_OP_IDENTIFY_CNS_NS:
			ret = dispatch_admin_queue_identify_namespace();
			break;
		case NVME_ADMIN_OP_IDENTIFY_CNS_CTRL:
			ret = dispatch_admin_queue_identify_controller();
			break;
		case NVME_ADMIN_OP_IDENTIFY_CNS_ACTIVE_NS_LIST:
			ret = dispatch_admin_queue_ns_active_list();
			ret = CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
			break;
		case NVME_ADMIN_OP_IDENTIFY_CNS_NS_DESC_LIST:
			ret = CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
			break;
		case NVME_ADMIN_OP_IDENTIFY_CNS_ALLOCATED_NS_LIST:
			ret = CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
			break;
		case NVME_ADMIN_OP_IDENTIFY_CNS_CTRL_LIST:
			ret = CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
			break;
		default:
			ret = CQ_ENTRY_DW3_SC_GENERIC_INVALID_OPCODE | CQ_ENTRY_DW3_SC_DNR;
			break;
	}

	return ret;
}

s32 dispatch_admin_queue_getlogpage()
{
	DEBUG_PRINT("dispatch_admin_queue_getlogpage : received NVMe getlogpage\r\n");

	return CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
}

s32 dispatch_admin_queue_set_features()
{
	DEBUG_PRINT("dispatch_admin_queue_set_features : received NVMe Set Features\r\n");

	u8 sq_entry_cdw10_sv = (sq_entry[10] & 0x80000000U) >> 31;
	u8 sq_entry_cdw10_fid = (sq_entry[10] & 0x000000ffU);
	DEBUG_PRINT("CDW10                   : %08x (sv = %u, fid = %u)\r\n", sq_entry[10], sq_entry_cdw10_sv, sq_entry_cdw10_fid);

	s32 ret;

	switch (sq_entry_cdw10_fid) {
		case NVME_ADMIN_OP_SET_FEATURES_FID_ASYNC_EVENT_CONFIG: {
			nvme_feat_aec = sq_entry[11];
			u8 sq_entry_cdw11_tln = (sq_entry[11] & 0x00000400U) >> 10;
			u8 sq_entry_cdw11_fan = (sq_entry[11] & 0x00000200U) >> 9;
			u8 sq_entry_cdw11_nan = (sq_entry[11] & 0x00000100U) >> 8;
			u8 sq_entry_cdw11_smart = (sq_entry[11] & 0x000000ffU);
			DEBUG_PRINT("dispatch_admin_queue_set_features : set features async event\r\n");
			DEBUG_PRINT("CDW11 (Async Event Cfg) : %08x (tln = %u, fan = %u, nan = %u, smart = %u)\r\n",
				sq_entry[11], sq_entry_cdw11_tln, sq_entry_cdw11_fan, sq_entry_cdw11_nan, sq_entry_cdw11_smart);
			cq_entry[0] = 0x00000000U;
			ret = CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
			break;
		}
		case NVME_ADMIN_OP_SET_FEATURES_FID_NUM_QUEUES: {
			u16 sq_entry_cdw11_ncqr = (sq_entry[11] & 0xffff0000U) >> 16;
			u16 sq_entry_cdw11_nsqr = (sq_entry[11] & 0x0000ffffU);
			DEBUG_PRINT("dispatch_admin_queue_set_features : set features num of queues\r\n");
			DEBUG_PRINT("CDW11 (Num of Queues)   : %08x (ncqr = %u, nsqr = %u)\r\n",
				sq_entry[11], sq_entry_cdw11_ncqr, sq_entry_cdw11_nsqr);
			if (sq_entry_cdw11_nsqr > (NVME_NSQ_QID_MAX - 1)) {
				nvme_io_nsqa = NVME_NSQ_QID_MAX - 1;
			} else {
				nvme_io_nsqa = sq_entry_cdw11_nsqr;
			}
			if (sq_entry_cdw11_ncqr > (NVME_NCQ_QID_MAX - 1)) {
				nvme_io_ncqa = NVME_NSQ_QID_MAX - 1;
			} else {
				nvme_io_ncqa = sq_entry_cdw11_ncqr;
			}
			cq_entry[0] = ((u32)nvme_io_ncqa << 16) | ((u32)nvme_io_nsqa);
			ret = CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
			break;
		}
		case NVME_ADMIN_OP_SET_FEATURES_FID_KEEP_ALIVE_TIMER:
			DEBUG_PRINT("dispatch_admin_queue_set_features : set features keep alive timer\r\n");
			ret = CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
			cq_entry[0] = 0x00000000U;
			break;
		case NVME_ADMIN_OP_SET_FEATURES_FID_HOST_ID:
			DEBUG_PRINT("dispatch_admin_queue_set_features : set features host idr\r\n");
			cq_entry[0] = 0x00000000U;
			ret = CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
			break;
		default:
			cq_entry[0] = 0x00000000U;
			ret = CQ_ENTRY_DW3_SC_GENERIC_INVALID_OPCODE | CQ_ENTRY_DW3_SC_DNR;
			break;
	}

	return ret;
}


s32 dispatch_admin_queue_create_cq()
{
	DEBUG_PRINT("dispatch_admin_queue_create_cq : received NVMe Create CQ\r\n");

	u16 sq_entry_cdw10_qsize = ((sq_entry[10] & 0xffff0000U) >> 16);
	u16 sq_entry_cdw10_qid   = (sq_entry[10] & 0x0000ffffU);
	u16 sq_entry_cdw11_iv    = (sq_entry[11] & 0xffff0000U) >> 16;
	u8  sq_entry_cdw11_ien   = (sq_entry[11] & 0x00000002U) >> 1;
	u8  sq_entry_cdw11_pc    = (sq_entry[11] & 0x00000001U);

	DEBUG_PRINT("CDW10                   : %08x (qidmax = %u, qid = %u)\r\n", sq_entry[10], (u32)sq_entry_cdw10_qsize, sq_entry_cdw10_qid);
	DEBUG_PRINT("CDW11                   : %08x (iv = %u, ien = %u, pc = %u)\r\n",
		sq_entry[11], sq_entry_cdw11_iv, sq_entry_cdw11_ien, sq_entry_cdw11_pc);

	if (! sq_entry_cdw11_pc) {
		DEBUG_PRINT("dispatch_admin_queue_create_cq : I/O cq with scattered memory buffer is not supported\r\n");
		return CQ_ENTRY_DW3_SC_DNR;
	}

	// assign SQ
	if (nvme_cqen[sq_entry_cdw10_qid] == 0) {
		nvme_cqen[sq_entry_cdw10_qid] = 1;
		nvme_cqmax[sq_entry_cdw10_qid] = sq_entry_cdw10_qsize;
		nvme_cqaddr[sq_entry_cdw10_qid] = (((u64)sq_entry[7]) << 32) + ((u64)sq_entry[6]);
		nvme_cqtdbl[sq_entry_cdw10_qid] = nvme_cqhdbl[sq_entry_cdw10_qid] = 0;
		if (sq_entry_cdw11_ien) {
			nvme_intv[sq_entry_cdw10_qid] = sq_entry_cdw11_iv;
			nvme_inten[sq_entry_cdw10_qid] = 1;
		} else {
			nvme_intv[sq_entry_cdw10_qid] = 0;
			nvme_inten[sq_entry_cdw10_qid] = 0;
		}
		writewea((u64)BAR0_ADDR + NVME_CQHDBL_BASE + (sq_entry_cdw10_qid * (8 << NVME_CAP_HI_DSTRD)),
			(u32)(nvme_cqhdbl[sq_entry_cdw10_qid]));

		DEBUG_PRINT("dispatch_admin_queue_create_cq : qid %u is ready for use\r\n", sq_entry_cdw10_qid);
		return CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
	} else {
		DEBUG_PRINT("dispatch_admin_queue_create_cq : qid %u is already in use\r\n", sq_entry_cdw10_qid);
		return CQ_ENTRY_DW3_SC_DNR;
	}
}

s32 dispatch_admin_queue_create_sq(){
	DEBUG_PRINT("dispatch_admin_queue_create_sq : received NVMe Create SQ\r\n");

	u16 sq_entry_cdw10_qsize = ((sq_entry[10] & 0xffff0000U) >> 16);
	u16 sq_entry_cdw10_qid   = (sq_entry[10] & 0x0000ffffU);
	u16 sq_entry_cdw11_cqid  = (sq_entry[11] & 0xffff0000U) >> 16;
	u8  sq_entry_cdw11_qprio = (sq_entry[11] & 0x00000006U) >> 1;
	u8  sq_entry_cdw11_pc    = (sq_entry[11] & 0x00000001U);

	DEBUG_PRINT("CDW10                   : %08x (qidmax = %u, qid = %u)\r\n", sq_entry[10], (u32)sq_entry_cdw10_qsize, sq_entry_cdw10_qid);
	DEBUG_PRINT("CDW11                   : %08x (cqid = %u, qprio = %u, pc = %u)\r\n",
		sq_entry[11], sq_entry_cdw11_cqid, sq_entry_cdw11_qprio, sq_entry_cdw11_pc);
	DEBUG_PRINT("CDW12                   : %08x\r\n", sq_entry[12]);
	DEBUG_PRINT("CDW13                   : %08x\r\n", sq_entry[13]);
	DEBUG_PRINT("CDW14                   : %08x\r\n", sq_entry[14]);
	DEBUG_PRINT("CDW15                   : %08x\r\n", sq_entry[15]);

	if (! sq_entry_cdw11_pc) {
		DEBUG_PRINT("dispatch_admin_queue_create_sq : I/O sq with scattered memory buffer is not supported\r\n");
		return CQ_ENTRY_DW3_SC_DNR;
	}

	// assign SQ
	if (nvme_sqen[sq_entry_cdw10_qid] == 0) {
		nvme_sqen[sq_entry_cdw10_qid] = 1;
		nvme_sqmax[sq_entry_cdw10_qid] = sq_entry_cdw10_qsize;
		nvme_sqaddr[sq_entry_cdw10_qid] = (((u64)sq_entry[7]) << 32) + ((u64)sq_entry[6]);
		nvme_sqtdbl[sq_entry_cdw10_qid] = nvme_sqhdbl[sq_entry_cdw10_qid] = 0;
		nvme_sq2cq[sq_entry_cdw10_qid] = sq_entry_cdw11_cqid;
		writewea((u64)BAR0_ADDR + NVME_SQTDBL_BASE + (sq_entry_cdw10_qid * (8 << NVME_CAP_HI_DSTRD)),
			(u32)(nvme_sqtdbl[sq_entry_cdw10_qid]));

		DEBUG_PRINT("dispatch_admin_queue_create_sq : qid %d is ready for use\r\n", sq_entry_cdw10_qid);
		return CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
	} else {
		DEBUG_PRINT("dispatch_admin_queue_create_sq : no vacant slot for CQ\r\n");
		return CQ_ENTRY_DW3_SC_DNR;
	}
}

s32 dispatch_admin_queue_delete_sq() {

	DEBUG_PRINT("dispatch_admin_queue_delete_sq : received NVMe Delete SQ\r\n");

	u16 sq_entry_cdw10_qid   = (sq_entry[10] & 0x0000ffffU);
	DEBUG_PRINT("CDW10                   : %08x (qid = %u)\r\n", sq_entry[10], sq_entry_cdw10_qid);

	if (! nvme_sqen[sq_entry_cdw10_qid]) {
		DEBUG_PRINT("dispatch_admin_queue_delete_sq : qid %u is not used\r\n", sq_entry_cdw10_qid);
		return CQ_ENTRY_DW3_SC_DNR;
	}
	nvme_sqen[sq_entry_cdw10_qid] = 0;
	DEBUG_PRINT("dispatch_admin_queue_delete_sq : qid %u disabled\r\n", sq_entry_cdw10_qid);

	return CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
}

s32 dispatch_admin_queue_delete_cq(){

	DEBUG_PRINT("dispatch_admin_queue_delete_cq : received NVMe Delete CQ\r\n");

	u16 sq_entry_cdw10_qid   = (sq_entry[10] & 0x0000ffffU);
	DEBUG_PRINT("CDW10                   : %08x (qid = %u)\r\n", sq_entry[10], sq_entry_cdw10_qid);

	if (! nvme_cqen[sq_entry_cdw10_qid]) {
		DEBUG_PRINT("dispatch_admin_queue_delete_cq : qid %u is not used\r\n", sq_entry_cdw10_qid);
		return CQ_ENTRY_DW3_SC_DNR;
	}
	nvme_cqen[sq_entry_cdw10_qid] = 0;
	DEBUG_PRINT("dispatch_admin_queue_delete_cq : qid %u disabled\r\n", sq_entry_cdw10_qid);

	return CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
}

s32 dispatch_admin_queue() {
	DEBUG_PRINT("dispatch_admin_queue : dispatch qid 0 admin queue entry\r\n");

	// extract queue entry
	u64 sq_entry_offset = nvme_sqaddr[0] + (nvme_sqhdbl[0] << nvme_cc_iosqes);
	DEBUG_PRINT("sq entry baseaddr       : %08x%08x\r\n", (u32)(sq_entry_offset >> 32), (u32)(sq_entry_offset & 0xffffffff));
	for (u32 i = 0; i < ((1 << nvme_cc_iosqes) >> 2); i ++) {
		sq_entry[i] = pcie_busmaster_read32(sq_entry_offset + (i * 4));
	}

	// decode them
	sq_entry_cdw0_cid  = (sq_entry[0] & 0xFFFF0000U) >> 16;
	u8 sq_entry_cdw0_psdt = (sq_entry[0] & 0x0000C000U) >> 14;
	u8 sq_entry_cdw0_fuse = (sq_entry[0] & 0x00000300U) >> 8;
	u8 sq_entry_cdw0_opc  = (sq_entry[0] & 0x000000FFU) >> 0;
	DEBUG_PRINT("CDW0                    : %08x (cid = 0x%04x, opcode = 0x%02x)\r\n", sq_entry[0], sq_entry_cdw0_cid, sq_entry_cdw0_opc);
	DEBUG_PRINT("CDW1  (NSID)            : %08x\r\n", sq_entry[1]);
	DEBUG_PRINT("CDW6  (DPTR_PRP1_LO)    : %08x\r\n", sq_entry[6]);
	DEBUG_PRINT("CDW7  (DPTR_PRP1_HI)    : %08x\r\n", sq_entry[7]);
	DEBUG_PRINT("CDW8  (DPTR_PRP2_LO)    : %08x\r\n", sq_entry[8]);
	DEBUG_PRINT("CDW9  (DPTR_PRP2_HI)    : %08x\r\n", sq_entry[9]);

	// branch based on opcode
	s32 ret;
	u8 comp_en = 0;
	switch (sq_entry_cdw0_opc) {
		case NVME_ADMIN_OP_DELETE_IO_SQ:
			comp_en = 1;
			cq_entry[0] = 0x00000000U;
			ret = dispatch_admin_queue_delete_sq();
			break;
		case NVME_ADMIN_OP_CREATE_IO_SQ:
			comp_en = 1;
			cq_entry[0] = 0x00000000U;
			ret = dispatch_admin_queue_create_sq();
			break;
		case NVME_ADMIN_OP_GET_LOG_PAGE:
			comp_en = 1;
			cq_entry[0] = 0x00000000U;
			ret = dispatch_admin_queue_getlogpage();
			break;
		case NVME_ADMIN_OP_DELETE_IO_CQ:
			comp_en = 1;
			cq_entry[0] = 0x00000000U;
			ret = dispatch_admin_queue_delete_cq();
			break;
		case NVME_ADMIN_OP_CREATE_IO_CQ:
			comp_en = 1;
			cq_entry[0] = 0x00000000U;
			ret = dispatch_admin_queue_create_cq();
			break;
		case NVME_ADMIN_OP_IDENTIFY:
			comp_en = 1;
			cq_entry[0] = 0x00000000U;
			ret = dispatch_admin_queue_identify();
			break;
		case NVME_ADMIN_OP_ABORT_CMD:
			comp_en = 1;
			cq_entry[0] = 0x00000000U;
			ret = CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
			break;
		case NVME_ADMIN_OP_SET_FEATURES:
			comp_en = 1;
			ret = dispatch_admin_queue_set_features();
			break;
		case NVME_ADMIN_OP_GET_FEATURES:
			comp_en = 1;
			cq_entry[0] = 0x00000000U;
			ret = dispatch_admin_queue_get_features();
			break;
		case NVME_ADMIN_OP_ASYNC_EVENT_REQ:
			comp_en = 0;
			ret = dispatch_admin_queue_async_event();
			cq_entry[0] = 0x00000000U;
			break;
		case NVME_ADMIN_OP_NS_ATTACH:
			comp_en = 1;
			cq_entry[0] = 0x00000000U;
			ret = CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
			break;
		case NVME_ADMIN_OP_KEEP_ALIVE:
			comp_en = 1;
			ret = CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
			cq_entry[0] = 0x00000000U;
			break;
		default :
			comp_en = 1;
			DEBUG_PRINT("dispatch_admin_queue : unimplemented opcode\r\n");
			ret = CQ_ENTRY_DW3_SC_GENERIC_INVALID_OPCODE | CQ_ENTRY_DW3_SC_DNR;
			cq_entry[0] = 0x00000000U;
			break;
	}

	if (comp_en) {
		ret = post_cq_entry(0, ret);
		DEBUG_PRINT("dispatch_admin_queue : completion message posted\r\n");
	} else {
		DEBUG_PRINT("dispatch_admin_queue : completion message skipped while sq entry contains async cmd\r\n");
	}

	// increment SQ head doorbell with roll-over consideration
	if (nvme_sqhdbl[0] == nvme_sqmax[0]) {
		nvme_sqhdbl[0] = 0;
	} else {
		nvme_sqhdbl[0] += 1;
	}

	return ret;
}

s32 dispatch_io_queue_flush(u16 sqid)
{
	s32 ret;
	ret = CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
	DEBUG_PRINT("CDW10                   : %08x\r\n", sq_entry[10]);
	DEBUG_PRINT("CDW11                   : %08x\r\n", sq_entry[11]);
	DEBUG_PRINT("CDW12                   : %08x\r\n", sq_entry[12]);
	DEBUG_PRINT("CDW13                   : %08x\r\n", sq_entry[13]);
	DEBUG_PRINT("CDW14                   : %08x\r\n", sq_entry[14]);
	DEBUG_PRINT("CDW15                   : %08x\r\n", sq_entry[15]);
	return ret;
}

s32 dispatch_io_queue_write(u16 sqid)
{
	s32 ret;
	ret = CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;

	// decode sq remainder
	u64 start_lba        = ((u64)sq_entry[11] << 32) & (u64)sq_entry[10];
	u8  cdw12_lr         = (sq_entry[12] & 0x80000000U) >> 31;      // [31]    Limited Retry
	u8  cdw12_fua        = (sq_entry[12] & 0x40000000U) >> 30;      // [30]    Force Unit Access
	u8  cdw12_prinfo     = (sq_entry[12] & 0x3c000000U) >> 26;      // [29:26] Protection Information Field
	u8  cdw12_dtype      = (sq_entry[12] & 0x00f00000U) >> 20;      // [23:20] Directive Type
	u16 cdw12_nlb        = (sq_entry[12] & 0x0000ffffU);            // [15:0]  Number of Logical Blocks
	u16 cdw13_dspec      = (sq_entry[13] & 0xffff0000U) >> 16;      // [31:16] Directive Specific
	u8  cdw13_dsm_incomp = (sq_entry[13] & 0x00000080U) >> 7;       // [7]     DSM Incompressible
	u8  cdw13_dsm_seqreq = (sq_entry[13] & 0x00000040U) >> 6;       // [6]     Sequential Request
	u8  cdw13_dsm_al     = (sq_entry[13] & 0x00000030U) >> 4;       // [5:4]   Access Latency
	u8  cdw13_dsm_af     = (sq_entry[13] & 0x0000000fU);            // [3:0]   Access Frequency
	DEBUG_PRINT("CDW10 (Starting LBA LO) : %08x\r\n", sq_entry[10]);
	DEBUG_PRINT("CDW11 (Starting LBA HI) : %08x\r\n", sq_entry[11]);
	DEBUG_PRINT("CDW12 (params)          : %08x\r\n", sq_entry[12]);
	DEBUG_PRINT("CDW13 (dataset mgmt)    : %08x\r\n", sq_entry[13]);
	DEBUG_PRINT("CDW14 (ILBRT)           : %08x\r\n", sq_entry[14]);
	DEBUG_PRINT("CDW15 (LBATM / LBAT)    : %08x\r\n", sq_entry[15]);

	// result will be stored into DPTR specified by sq_entry[6,7,8,9]
	// PRP2 entry (sq_entry[8, 9]) is one of below:
	//
	//   data transfer crosses | includes example case | PBA offset | transfer size        | what PRP2 dptr point to
	//   ----------------------+-----------------------+------------+----------------------+-----------------------------------
	//   no page boundary      |           pattern (a) |          n | 1 to (4096-n)        | nothing (all data stored in PRP1)
	//   exact 1 page boundary | pattern (b-i), (b-ii) |          n | (4097-n) to (8192-n) | base address of the second memory page
	//   2 or more boundaries  | pattern (c-i), (c-ii) |          n | (8193-n) or more     | PRP List pointer
	//
	// if requested transfer size exceeds 1 PRP List supported size, last pointer entry of PRP List will be the base address of next PRP List

	u32 PAGE_SIZE = (0x00000001U << (12 + nvme_cc_mps));
	u32 PRP_OFFSET_MASK = PAGE_SIZE - 0x00000001U;
	u64 prp1_addr = (((u64)sq_entry[7]) << 32) + ((u64)sq_entry[6]);
	u64 prp2_addr = (((u64)sq_entry[9]) << 32) + ((u64)sq_entry[8]);
	u64 disk_offset = (((u64)sq_entry[11] << 32) | (u64)sq_entry[10]) * LBA_SIZE;
	u32 bytes_remaining = ((u32)cdw12_nlb + 1) * LBA_SIZE;
	u32 pba_offset = prp1_addr & PRP_OFFSET_MASK;

	// transfer data from PRP1 memory page
	u32 prp1_wsize = (bytes_remaining <= (PAGE_SIZE - pba_offset)) ? bytes_remaining : PAGE_SIZE - pba_offset;
	DEBUG_PRINT("dispatch_io_queue_write : transfer %d bytes from PRP1, PBA offset = %d\r\n", prp1_wsize, pba_offset);
	pcie_busmaster_memread(prp1_addr, local_buffer, prp1_wsize);
	memwrite_ea(SDRAM_ADDR + disk_offset, local_buffer, prp1_wsize);
	disk_offset += prp1_wsize;
	bytes_remaining -= prp1_wsize;

	if (bytes_remaining > PAGE_SIZE) {
		// treat PRP2 as PRP List
		u64 prp_entry_addr = prp2_addr;
		while (bytes_remaining > 0) {
			// dereference PRP body from PRP pointer entry
			u64 prp_body = (u64)pcie_busmaster_read32(prp_entry_addr) | ((u64)pcie_busmaster_read32(prp_entry_addr + 4) << 32);
			u32 bytes_to_transfer = bytes_remaining < PAGE_SIZE ? bytes_remaining : PAGE_SIZE;
			DEBUG_PRINT("dispatch_io_queue_write : transfer %d bytes from PRP %08x%08x\r\n",
				bytes_to_transfer,
				(u32)(prp_body >> 32),
				(u32)(prp_body & 0xffffffff));

			// transfer data from PRP body
			pcie_busmaster_memread(prp_body, local_buffer, bytes_to_transfer);
			memwrite_ea(SDRAM_ADDR + disk_offset, local_buffer, bytes_to_transfer);
			disk_offset += bytes_to_transfer;
			bytes_remaining -= bytes_to_transfer;
			prp_entry_addr += 8;

			if (prp_entry_addr == (prp_entry_addr & (~PRP_OFFSET_MASK)) + PAGE_SIZE - 8 && bytes_remaining > PAGE_SIZE) {
				// if next prp_entry is last entry of PRP list and extra PRP list is needed for transfer bytes remaining,
				// last entry of PRP list turned into next PRP list
				prp_entry_addr = (u64)pcie_busmaster_read32(prp_entry_addr) | ((u64)pcie_busmaster_read32(prp_entry_addr + 4) << 32);
			}
		}
	} else if (bytes_remaining > 0) {
		// transfer data from raw PRP2 memory page
		DEBUG_PRINT("dispatch_io_queue_write : transfer %d bytes from raw PRP2\r\n", bytes_remaining);
		pcie_busmaster_memread(prp2_addr, local_buffer, bytes_remaining);
		memwrite_ea(SDRAM_ADDR + disk_offset, local_buffer, bytes_remaining);
		disk_offset += bytes_remaining;
		bytes_remaining -= bytes_remaining;
	}

	ret = CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
	return ret;
}

s32 dispatch_io_queue_read(u16 sqid)
{
	s32 ret;

	// decode sq remainder
	u64 start_lba        = ((u64)sq_entry[11] << 32) & (u64)sq_entry[10];
	u8  cdw12_lr         = (sq_entry[12] & 0x80000000U) >> 31;      // [31]    Limited Retry
	u8  cdw12_fua        = (sq_entry[12] & 0x40000000U) >> 30;      // [30]    Force Unit Access
	u8  cdw12_prinfo     = (sq_entry[12] & 0x3c000000U) >> 26;      // [29:26] Protection Information Field
	u16 cdw12_nlb        = (sq_entry[12] & 0x0000ffffU);            // [15:0]  Number of Logical Blocks
	u8  cdw13_dsm_incomp = (sq_entry[13] & 0x00000080U) >> 7;       // [7]     DSM Incompressible
	u8  cdw13_dsm_seqreq = (sq_entry[13] & 0x00000040U) >> 6;       // [6]     Sequential Request
	u8  cdw13_dsm_al     = (sq_entry[13] & 0x00000030U) >> 4;       // [5:4]   Access Latency
	u8  cdw13_dsm_af     = (sq_entry[13] & 0x0000000fU);            // [3:0]   Access Frequency
	DEBUG_PRINT("CDW10 (Starting LBA LO) : %08x\r\n", sq_entry[10]);
	DEBUG_PRINT("CDW11 (Starting LBA HI) : %08x\r\n", sq_entry[11]);
	DEBUG_PRINT("CDW12 (params)          : %08x\r\n", sq_entry[12]);
	DEBUG_PRINT("CDW13 (dataset mgmt)    : %08x\r\n", sq_entry[13]);
	DEBUG_PRINT("CDW14 (EILBRT)          : %08x\r\n", sq_entry[14]);
	DEBUG_PRINT("CDW15 (ELBATM / ELBAT)  : %08x\r\n", sq_entry[15]);

	// result will be stored into DPTR specified by sq_entry[6,7,8,9]
	// PRP2 entry (sq_entry[8, 9]) is one of below:
	//
	//   data transfer crosses | includes example case | PBA offset | transfer size        | what PRP2 dptr point to
	//   ----------------------+-----------------------+------------+----------------------+-----------------------------------
	//   no page boundary      |           pattern (a) |          n | 1 to (4096-n)        | nothing (all data stored in PRP1)
	//   exact 1 page boundary | pattern (b-i), (b-ii) |          n | (4097-n) to (8192-n) | base address of the second memory page
	//   2 or more boundaries  | pattern (c-i), (c-ii) |          n | (8193-n) or more     | PRP List pointer
	//
	// if requested transfer size exceeds 1 PRP List supported size, last pointer entry of PRP List will be the base address of next PRP List

	u32 PAGE_SIZE = (0x00000001U << (12 + nvme_cc_mps));
	u32 PRP_OFFSET_MASK = PAGE_SIZE - 0x00000001U;
	u64 prp1_addr = (((u64)sq_entry[7]) << 32) + ((u64)sq_entry[6]);
	u64 prp2_addr = (((u64)sq_entry[9]) << 32) + ((u64)sq_entry[8]);
	u64 disk_offset = (((u64)sq_entry[11] << 32) | (u64)sq_entry[10]) * LBA_SIZE;
	u32 bytes_remaining = ((u32)cdw12_nlb + 1) * LBA_SIZE;
	u32 pba_offset = prp1_addr & PRP_OFFSET_MASK;

	// transfer data to PRP1 memory page
	u32 prp1_rsize = (bytes_remaining <= (PAGE_SIZE - pba_offset)) ? bytes_remaining : PAGE_SIZE - pba_offset;
	DEBUG_PRINT("dispatch_io_queue_read : transfer %d bytes to PRP1, PBA offset = %d\r\n", prp1_rsize, pba_offset);
	memread_ea(SDRAM_ADDR + disk_offset, local_buffer, prp1_rsize);
	pcie_busmaster_memwrite(prp1_addr, local_buffer, prp1_rsize);

	disk_offset += prp1_rsize;
	bytes_remaining -= prp1_rsize;

	if (bytes_remaining > PAGE_SIZE) {
		// treat PRP2 as PRP List
		u64 prp_entry_addr = prp2_addr;
		while (bytes_remaining > 0) {
			// dereference PRP body from PRP pointer entry
			u64 prp_body = (u64)pcie_busmaster_read32(prp_entry_addr) | ((u64)pcie_busmaster_read32(prp_entry_addr + 4) << 32);
			u32 bytes_to_transfer = bytes_remaining < PAGE_SIZE ? bytes_remaining : PAGE_SIZE;
			DEBUG_PRINT("dispatch_io_queue_read : transfer %d bytes to PRP %08x%08x\r\n",
				bytes_to_transfer,
				(u32)(prp_body >> 32),
				(u32)(prp_body & 0xffffffff));

			// transfer data to PRP body
			memread_ea(SDRAM_ADDR + disk_offset, local_buffer, bytes_to_transfer);
			pcie_busmaster_memwrite(prp_body, local_buffer, bytes_to_transfer);
			disk_offset += bytes_to_transfer;
			bytes_remaining -= bytes_to_transfer;
			prp_entry_addr += 8;

			if (prp_entry_addr == (prp_entry_addr & (~PRP_OFFSET_MASK)) + PAGE_SIZE - 8 && bytes_remaining > PAGE_SIZE) {
				// if next prp_entry is last entry of PRP list and extra PRP list is needed for transfer bytes remaining,
				// last entry of PRP list turned into next PRP list
				prp_entry_addr = (u64)pcie_busmaster_read32(prp_entry_addr) | ((u64)pcie_busmaster_read32(prp_entry_addr + 4) << 32);
			}
		}
	} else if (bytes_remaining > 0) {
		// transfer data to raw PRP2 memory page
		DEBUG_PRINT("dispatch_io_queue_read : transfer %d bytes to raw PRP2\r\n", bytes_remaining);
		memread_ea(SDRAM_ADDR + disk_offset, local_buffer, bytes_remaining);
		pcie_busmaster_memwrite(prp2_addr, local_buffer, bytes_remaining);
		disk_offset += bytes_remaining;
		bytes_remaining -= bytes_remaining;
	}

	ret = CQ_ENTRY_DW3_SC_GENERIC_SUCCESS;
	return ret;
}

s32 dispatch_io_queue(u16 sqid)
{
	DEBUG_PRINT("dispatch_io_queue : dispatch sqid %u entry\r\n");

	// extract queue entry
	for (u32 i = 0; i < ((1 << nvme_cc_iosqes) >> 2); i ++) {
		sq_entry[i] = pcie_busmaster_read32(nvme_sqaddr[sqid] + (nvme_sqhdbl[sqid] << nvme_cc_iosqes) + (i * 4));
	}

	// decode them
	sq_entry_cdw0_cid  = (sq_entry[0] & 0xFFFF0000U) >> 16;
	u8 sq_entry_cdw0_psdt = (sq_entry[0] & 0x0000C000U) >> 14;
	u8 sq_entry_cdw0_fuse = (sq_entry[0] & 0x00000300U) >> 8;
	u8 sq_entry_cdw0_opc  = (sq_entry[0] & 0x000000FFU) >> 0;
	DEBUG_PRINT("CDW0                    : %08x (cid = 0x%04x, opcode = 0x%02x)\r\n", sq_entry[0], sq_entry_cdw0_cid, sq_entry_cdw0_opc);
	DEBUG_PRINT("CDW1  (NSID)            : %08x\r\n", sq_entry[1]);
	DEBUG_PRINT("CDW6  (DPTR_PRP1_LO)    : %08x\r\n", sq_entry[6]);
	DEBUG_PRINT("CDW7  (DPTR_PRP1_HI)    : %08x\r\n", sq_entry[7]);
	DEBUG_PRINT("CDW8  (DPTR_PRP2_LO)    : %08x\r\n", sq_entry[8]);
	DEBUG_PRINT("CDW9  (DPTR_PRP2_HI)    : %08x\r\n", sq_entry[9]);

	// branch based on opcode
	s32 ret;
	u8 comp_en = 0;
	switch (sq_entry_cdw0_opc) {
		case NVME_IO_OP_FLUSH:
			comp_en = 1;
			ret = dispatch_io_queue_flush(sqid);
			break;
		case NVME_IO_OP_WRITE:
			comp_en = 1;
			ret = dispatch_io_queue_write(sqid);
			break;
		case NVME_IO_OP_READ:
			comp_en = 1;
			ret = dispatch_io_queue_read(sqid);
			break;
		default :
			DEBUG_PRINT("dispatch_io_queue : unimplemented opcode\r\n");
			comp_en = 1;
			ret = CQ_ENTRY_DW3_SC_GENERIC_INVALID_OPCODE | CQ_ENTRY_DW3_SC_DNR;
			break;
	}

	if (comp_en) {
		u16 cqid = nvme_sq2cq[sqid];
		ret = post_cq_entry(cqid, ret);
		DEBUG_PRINT("dispatch_io_queue : completion message posted\r\n");
	} else {
		DEBUG_PRINT("dispatch_io_queue : completion message skipped\r\n");
	}

	// increment SQ head doorbell with roll-over consideration
	if (nvme_sqhdbl[sqid] == nvme_sqmax[sqid]) {
		nvme_sqhdbl[sqid] = 0;
	} else {
		nvme_sqhdbl[sqid] += 1;
	}

	return ret;
}

int main()
{
	u32 status;
	usleep(3000000);

	DEBUG_PRINT("main : initializing platform... ");
	init_platform();
	DEBUG_PRINT("done\r\n");

	//-----
	// Initialize PCIe Firewall
	//-----
	// init PCIe firewall
	DEBUG_PRINT("main : pcie tx firewall: version: %08x\r\n", pcie_fw_in_regs->ip_version);
	DEBUG_PRINT("main : pcie tx firewall: mi fault status: %08x\r\n", pcie_fw_in_regs->mi_side_fault_status);
	DEBUG_PRINT("main : pcie tx firewall: si fault status: %08x\r\n", pcie_fw_in_regs->si_side_fault_status);
	DEBUG_PRINT("main : pcie tx firewall: unblocking firewall... ");
	pcie_fw_in_regs->mi_side_unblock_control = 1;
	while(pcie_fw_in_regs->mi_side_unblock_control & 1);
	pcie_fw_in_regs->si_side_unblock_control = 1;
	while(pcie_fw_in_regs->si_side_unblock_control & 1);
	DEBUG_PRINT("done\r\n");
	DEBUG_PRINT("main : pcie rx firewall: version: %08x\r\n", pcie_fw_out_regs->ip_version);
	DEBUG_PRINT("main : pcie rx firewall: mi fault status: %08x\r\n", pcie_fw_out_regs->mi_side_fault_status);
	DEBUG_PRINT("main : pcie rx firewall: si fault status: %08x\r\n", pcie_fw_out_regs->si_side_fault_status);
	DEBUG_PRINT("main : pcie rx firewall: unblocking firewall... ");
	pcie_fw_out_regs->mi_side_unblock_control = 1;
	while(pcie_fw_out_regs->mi_side_unblock_control & 1);
	pcie_fw_out_regs->si_side_unblock_control = 1;
	while(pcie_fw_out_regs->si_side_unblock_control & 1);
	DEBUG_PRINT("done\r\n");

	// Dump last doorbells
	for (u16 qid = 0; qid <= NVME_NSQ_QID_MAX; qid ++) {
		u16 sqtdbl = (readwea((u64)BAR0_ADDR + NVME_SQTDBL_BASE + (qid * (8 << NVME_CAP_HI_DSTRD))) & NVME_SQTDBL_SQT_MASK) >> NVME_SQTDBL_SQT_SHIFT;
		u16 cqhdbl = (readwea((u64)BAR0_ADDR + NVME_CQHDBL_BASE + (qid * (8 << NVME_CAP_HI_DSTRD))) & NVME_CQHDBL_CQH_MASK) >> NVME_CQHDBL_CQH_SHIFT;

		DEBUG_PRINT("Queue %03d: SQ tail doorbell = %d, CQ head doorbell = %d\r\n", qid, sqtdbl, cqhdbl);
	}

	// SDRAM test
	writewea(SDRAM_ADDR, 0xaabbccddU);
	DEBUG_PRINT("SDRAM readout test : %08x\r\n", readwea(SDRAM_ADDR));

	//--------------------------------------------------------------------------
	// init peripherals
	//--------------------------------------------------------------------------
	// init LED GPIO
	gpio_led_cfg.DeviceId = XPAR_GPIO_LED_DEVICE_ID;
	status = XGpio_CfgInitialize(&gpio_led, &gpio_led_cfg, XPAR_GPIO_LED_BASEADDR);
	if(status != XST_SUCCESS){
		DEBUG_PRINT("main : XPAR_GPIO_LED_DEVICE_ID initialization failed.\r\n");
		return XST_FAILURE;
	}

	XGpio_SetDataDirection(&gpio_led, 1, 0x00000000);
	gpio_led_stat = 0xff;
	XGpio_DiscreteWrite(&gpio_led, 1, gpio_led_stat);

	// init Timer Interrupt
	status = XIntc_Initialize(&intc, XPAR_MB_SYSTEM_INTC_DEVICE_ID);
	if (status != XST_SUCCESS) {
		DEBUG_PRINT("main : intc init error\r\n");
		return status;
	}


	status = XTmrCtr_Initialize(&tmr, XPAR_MB_SYSTEM_TIMER_DEVICE_ID);
	if (status != XST_SUCCESS){
		DEBUG_PRINT("main : timer init error\r\n");
		return status;
	}

	status = XIntc_Connect(&intc, XPAR_INTC_0_TMRCTR_0_VEC_ID, (XInterruptHandler)XTmrCtr_InterruptHandler, (void*)&tmr);
	if (status != XST_SUCCESS) {
		DEBUG_PRINT("main : connect error\r\n");
		return status;
	}

	status = XIntc_Start(&intc, XIN_REAL_MODE);
	if (status != XST_SUCCESS) {
		DEBUG_PRINT("main : intc start error\r\n");
		return status;
	}
	XIntc_Enable(&intc, XPAR_INTC_0_TMRCTR_0_VEC_ID);

	XTmrCtr_SetHandler(&tmr, (void*)timer_handler, (void*)0);
	microblaze_enable_interrupts();

	XTmrCtr_SetOptions(&tmr, 0, XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION | XTC_DOWN_COUNT_OPTION);
	XTmrCtr_SetResetValue(&tmr, 0, 66666667);
	XTmrCtr_Start(&tmr, 0);

	//--------------------------------------------------------------------------
	// initialize bar0 mmap memory
	//--------------------------------------------------------------------------
	// clear bar0 with all zeroes
	DEBUG_PRINT("main : clear bar0\r\n");
	for (u32 i = 0; i < BAR0_SIZE; i += 4) {
		writewea((u64)BAR0_ADDR + i, 0x00000000);
	}

	// print MSI/MSI-X Control Reg
#ifdef __PCIE_BUSMASTER_7SERIES__
	DEBUG_PRINT("MSI control (48h) : 0x%08lx\r\n", readwea((u64)XPAR_PCIE_SYSTEM_PCIE_BASEADDR + 0x48));
#endif
#ifdef __PCIE_BUSMASTER_ULTRASCALE__
	DEBUG_PRINT("MSI-X : todo \r\n");
#endif

	// set controller capabilities
	writewea((u64)BAR0_ADDR + NVME_CAP_LOWORD_OFFSET, NVME_CAP_LOWORD);
	writewea((u64)BAR0_ADDR + NVME_CAP_HIWORD_OFFSET, NVME_CAP_HIWORD);

	// set version
	writewea((u64)BAR0_ADDR + NVME_VS_OFFSET, NVME_VS);

	//--------------------------------------------------------------------------
	// set up IRQ block
	//--------------------------------------------------------------------------
#ifdef __PCIE_BUSMASTER_ULTRASCALE__
	// set IRQ Block iv mapping
	DEBUG_PRINT("main : set up IRQ block registers\r\n");
	DEBUG_PRINT("main : IRQ block ident = 0x%08x\r\n", readwea((u64)XPAR_PCIE_SYSTEM_REMAPPER_BASEADDR + PCIE_REG_IRQBLOCK_IDENT));
	writewea((u64)XPAR_PCIE_SYSTEM_REMAPPER_BASEADDR + PCIE_REG_IRQBLOCK_VEC_NUM_0, 0x03020100U);
	writewea((u64)XPAR_PCIE_SYSTEM_REMAPPER_BASEADDR + PCIE_REG_IRQBLOCK_VEC_NUM_1, 0x07060504U);
	writewea((u64)XPAR_PCIE_SYSTEM_REMAPPER_BASEADDR + PCIE_REG_IRQBLOCK_VEC_NUM_2, 0x0b0a0908U);
	writewea((u64)XPAR_PCIE_SYSTEM_REMAPPER_BASEADDR + PCIE_REG_IRQBLOCK_VEC_NUM_3, 0x0f0e0d0cU);
#endif

	//--------------------------------------------------------------------------
	// main polling loop
	//--------------------------------------------------------------------------
	u8 supress_stdby_log = 0;

	while (1) {
		// read BAR0 controller config
		nvme_cc = readwea((u64)BAR0_ADDR + NVME_CC_OFFSET);
		nvme_cc_en = (nvme_cc & NVME_CC_EN_MASK) >> NVME_CC_EN_SHIFT;
		nvme_cc_css = (nvme_cc & NVME_CC_CSS_MASK) >> NVME_CC_CSS_SHIFT;
		nvme_cc_mps = (nvme_cc & NVME_CC_MPS_MASK) >> NVME_CC_MPS_SHIFT;
		nvme_cc_ams = (nvme_cc & NVME_CC_AMS_MASK) >> NVME_CC_AMS_SHIFT;
		nvme_cc_shn = (nvme_cc & NVME_CC_SHN_MASK) >> NVME_CC_SHN_SHIFT;
		nvme_cc_iosqes = (nvme_cc & NVME_CC_IOSQES_MASK) >> NVME_CC_IOSQES_SHIFT;
		nvme_cc_iocqes = (nvme_cc & NVME_CC_IOCQES_MASK) >> NVME_CC_IOCQES_SHIFT;

		// read SQ tail doorbell / CQ head doorbell
		for (u16 qid = 0; qid <= NVME_NSQ_QID_MAX; qid ++) {
			nvme_sqtdbl[qid] = (readwea((u64)BAR0_ADDR + NVME_SQTDBL_BASE + (qid * (8 << NVME_CAP_HI_DSTRD))) & NVME_SQTDBL_SQT_MASK) >> NVME_SQTDBL_SQT_SHIFT;
		}
		for (u16 qid = 0; qid <= NVME_NCQ_QID_MAX; qid ++) {
			nvme_cqhdbl[qid] = (readwea((u64)BAR0_ADDR + NVME_CQHDBL_BASE + (qid * (8 << NVME_CAP_HI_DSTRD))) & NVME_CQHDBL_CQH_MASK) >> NVME_CQHDBL_CQH_SHIFT;
		}

		// nvme_cc_en means "host requests controller running or suspended"
		// while nvme_csts_rdy means "controller is running or suspended"
		if ((!nvme_csts_rdy) & nvme_cc_en) {
			// ---- controller on bring up ----
			DEBUG_PRINT("main : ---- controller on bring up ----------------------------------------------------\r\n");
			DEBUG_PRINT("main : cc.en = 0x%01x, csts.rdy = 0x%01x\r\n", nvme_cc_en, nvme_csts_rdy);

			// reset doorbell register
			DEBUG_PRINT("main : reset all queue info\r\n");
			for (u16 qid = 0; qid <= NVME_NSQ_QID_MAX; qid ++) {
				nvme_sqtdbl[qid] = nvme_sqhdbl[qid] = 0;
				writewea((u64)BAR0_ADDR + NVME_SQTDBL_BASE + (qid * (8 << NVME_CAP_HI_DSTRD)), (u32)(nvme_sqtdbl[qid]));
			}
			for (u16 qid = 0; qid <= NVME_NCQ_QID_MAX; qid ++) {
				nvme_cqhdbl[qid] = nvme_cqtdbl[qid] = 0;
				writewea((u64)BAR0_ADDR + NVME_CQHDBL_BASE + (qid * (8 << NVME_CAP_HI_DSTRD)), (u32)(nvme_cqhdbl[qid]));
			}

			// reset SQ/CQ info
			for (s16 sqid = 1; sqid <= NVME_NSQ_QID_MAX; sqid ++) {
				nvme_sqen[sqid] = 0;
				nvme_sqmax[sqid] = 0;
				nvme_sq2cq[sqid] = 0;
			}
			for (s16 cqid = 1; cqid <= NVME_NCQ_QID_MAX; cqid ++) {
				nvme_cqen[cqid] = 0;
				nvme_cqmax[cqid] = 0;
				nvme_intv[cqid] = 0;
				nvme_inten[cqid] = 0;
			}

			// read & init admin SQ/CQ information
			// note : MSI-X interrupt enable mask bit will be released later
			nvme_sqen[0] = 1;
			nvme_cqen[0] = 1;
			nvme_sq2cq[0] = 0;
			nvme_sqaddr[0] = readwea((u64)BAR0_ADDR + NVME_ASQ_HI_OFFSET);
			nvme_sqaddr[0] = (nvme_sqaddr[0] << 32) | readwea((u64)BAR0_ADDR + NVME_ASQ_LO_OFFSET);
			nvme_cqaddr[0] = readwea((u64)BAR0_ADDR + NVME_ACQ_HI_OFFSET);
			nvme_cqaddr[0] = (nvme_cqaddr[0] << 32) | readwea((u64)BAR0_ADDR + NVME_ACQ_LO_OFFSET);
			u32 nvme_aqa = readwea((u64)BAR0_ADDR + NVME_AQA_OFFSET);
			nvme_sqmax[0] = (nvme_aqa & NVME_AQA_ASQS_MASK) >> NVME_AQA_ASQS_SHIFT;
			nvme_cqmax[0] = (nvme_aqa & NVME_AQA_ACQS_MASK) >> NVME_AQA_ACQS_SHIFT;
			nvme_intv[0] = 0;
			nvme_io_nsqa = 0;
			nvme_io_ncqa = 0;
			DEBUG_PRINT("main : admin SQ max = %u, base addr = 0x%08x%08x\r\n", (u32)nvme_sqmax[0], (u32)(nvme_sqaddr[0] >> 32), (u32)nvme_sqaddr[0]);
			DEBUG_PRINT("main : admin CQ max = %u, base addr = 0x%08x%08x\r\n", (u32)nvme_cqmax[0], (u32)(nvme_cqaddr[0] >> 32), (u32)nvme_cqaddr[0]);


			// change ready state
			DEBUG_PRINT("main : transition to running state\r\n");
			nvme_csts_rdy = 1;
			nvme_csts_shst = 0;
			nvme_csts = 0x00000000;
			nvme_csts |= (((u32)nvme_csts_rdy) << NVME_CSTS_RDY_SHIFT);
			nvme_csts |= (((u32)nvme_csts_cfs) << NVME_CSTS_CFS_SHIFT);
			nvme_csts |= (((u32)nvme_csts_shst) << NVME_CSTS_SHST_SHIFT);
			nvme_csts |= (((u32)nvme_csts_nssro) << NVME_CSTS_NSSRO_SHIFT);
			nvme_csts |= (((u32)nvme_csts_pp) << NVME_CSTS_PP_SHIFT);
			writewea((u64)BAR0_ADDR + NVME_CSTS_OFFSET, nvme_csts);

			// release supressing stdby log
			supress_stdby_log = 0;

			DEBUG_PRINT("main : ---- controller on running -----------------------------------------------------\r\n");

		} else if (nvme_csts_rdy & nvme_cc_en) {
			// respond to shutdown request
			if (nvme_cc_shn != 0) {
				nvme_csts_rdy = 1;
				nvme_csts_shst = 2;
				nvme_csts = 0x00000000;
				nvme_csts |= (((u32)nvme_csts_rdy) << NVME_CSTS_RDY_SHIFT);
				nvme_csts |= (((u32)nvme_csts_cfs) << NVME_CSTS_CFS_SHIFT);
				nvme_csts |= (((u32)nvme_csts_shst) << NVME_CSTS_SHST_SHIFT);
				nvme_csts |= (((u32)nvme_csts_nssro) << NVME_CSTS_NSSRO_SHIFT);
				nvme_csts |= (((u32)nvme_csts_pp) << NVME_CSTS_PP_SHIFT);
				writewea((u64)BAR0_ADDR + NVME_CSTS_OFFSET, nvme_csts);
			}

			// ---- controller on running ----
			// update interrupt mask
			for (u16 cqid = 0; cqid < NVME_NSQ_QID_MAX; cqid ++) {
				if (! nvme_cqen[cqid]) {
					continue;
				}
#ifdef __PCIE_BUSMASTER_7SERIES__
				u8 ret = (readwea((u64)XPAR_PCIE_SYSTEM_PCIE_BASEADDR + 0x58) >> cqid) & 0x00000001U;
#endif
#ifdef __PCIE_BUSMASTER_ULTRASCALE__
				u8 ret = readwea((u64)XPAR_PCIE_SYSTEM_REMAPPER_BASEADDR + PCIE_REG_MSIX_TBL_BASEADDR +
						PCIE_REG_MSIX_TBL_STRIDE * nvme_intv[cqid] + PCIE_REG_MSIX_TBL_CTRL) & 0x00000001U;
#endif
				if (ret) {
					nvme_inten[cqid] = 0;
				} else {
					nvme_inten[cqid] = 1;
				}
			}

			for (u16 sqid = 0; sqid <= NVME_NSQ_QID_MAX; sqid ++) {
				if (nvme_sqen[sqid] && nvme_sqtdbl[sqid] != nvme_sqhdbl[sqid]) {
					for (u16 s = 0; s <= NVME_NSQ_QID_MAX; s ++) {
						if (!nvme_sqen[s]) {
							continue;
						}
						u16 c = nvme_sq2cq[s];
						if (s == 0) {
							DEBUG_PRINT("main : admin SQ tail doorbell = %u, head doorbell = %u\r\n", nvme_sqtdbl[0], nvme_sqhdbl[0]);
						} else {
							DEBUG_PRINT("main : I/O SQ (qid:%u) tail doorbell = %u, head doorbell = %u\r\n",
								s, nvme_sqtdbl[s], nvme_sqhdbl[s]);
						}
						if (c == 0) {
							DEBUG_PRINT("main : admin CQ head doorbell = %u, tail doorbell = %u\r\n", nvme_cqhdbl[0], nvme_cqtdbl[0]);
						} else {
							DEBUG_PRINT("main : I/O CQ (qid:%u) tail doorbell = %u, head doorbell = %u\r\n",
								c, nvme_cqtdbl[c], nvme_cqhdbl[c]);
						}

#ifdef __PCIE_BUSMASTER_7SERIES__
						DEBUG_PRINT("main : CQ %u th uses No. %u interrupt, enable = %u\r\n",
								c,
								nvme_intv[c],
								nvme_inten[c]);
#endif
#ifdef __PCIE_BUSMASTER_ULTRASCALE__
						DEBUG_PRINT("main : CQ %u irq addr = 0x%08x%08x, interrupt vector = %u, enable = %u\r\n",
								c,
								readwea((u64)XPAR_PCIE_SYSTEM_REMAPPER_BASEADDR + PCIE_REG_MSIX_TBL_BASEADDR + PCIE_REG_MSIX_TBL_STRIDE * nvme_intv[c] + PCIE_REG_MSIX_TBL_ADDR_HI),
								readwea((u64)XPAR_PCIE_SYSTEM_REMAPPER_BASEADDR + PCIE_REG_MSIX_TBL_BASEADDR + PCIE_REG_MSIX_TBL_STRIDE * nvme_intv[c] + PCIE_REG_MSIX_TBL_ADDR_LO),
								nvme_intv[c],
								nvme_inten[c]);
#endif
					}
					if (sqid == 0) {
						dispatch_admin_queue();
					} else {
						dispatch_io_queue(sqid);
					}
					DEBUG_PRINT("main : ---- controller on running -----------------------------------------------------\r\n");
				}
			}
		} else if (nvme_csts_rdy & (! nvme_cc_en)) {
			// ---- controller on halt ----
			DEBUG_PRINT("main : ---- controller on shutting down -----------------------------------------------\r\n");
			DEBUG_PRINT("main : cc.en = 0x%01x, csts.rdy = 0x%01x, cc.shn = 0x%01x\r\n", nvme_cc_en, nvme_csts_rdy, nvme_cc_shn);
			DEBUG_PRINT("main : transition to standby state\r\n");
			nvme_csts_rdy = 0;
			nvme_csts = 0x00000000;
			nvme_csts |= (((u32)nvme_csts_rdy) << NVME_CSTS_RDY_SHIFT);
			nvme_csts |= (((u32)nvme_csts_cfs) << NVME_CSTS_CFS_SHIFT);
			nvme_csts |= (((u32)nvme_csts_shst) << NVME_CSTS_SHST_SHIFT);
			nvme_csts |= (((u32)nvme_csts_nssro) << NVME_CSTS_NSSRO_SHIFT);
			nvme_csts |= (((u32)nvme_csts_pp) << NVME_CSTS_PP_SHIFT);
			writewea((u64)BAR0_ADDR + NVME_CSTS_OFFSET, nvme_csts);
		} else {
			if (! supress_stdby_log) {
				DEBUG_PRINT("main : ---- controller on stand by ----------------------------------------------------\r\n");
				DEBUG_PRINT("main : cc.en = 0x%01x, csts.rdy = 0x%01x\r\n", nvme_cc_en, nvme_csts_rdy);
				supress_stdby_log = 1;
			}
		}
	}

	cleanup_platform();
	return 0;
}

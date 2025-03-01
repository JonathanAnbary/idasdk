#include <sys/types.h>
#include <stdbool.h>

enum inftag_t
{
  INF_VERSION               =  0,
  INF_PROCNAME              =  1,
  INF_GENFLAGS              =  2,
  INF_LFLAGS                =  3,
  INF_DATABASE_CHANGE_COUNT =  4,
  INF_FILETYPE              =  5,
  INF_OSTYPE                =  6,
  INF_APPTYPE               =  7,
  INF_ASMTYPE               =  8,
  INF_SPECSEGS              =  9,
  INF_AF                    = 10,
  INF_AF2                   = 11,
  INF_BASEADDR              = 12,
  INF_START_SS              = 13,
  INF_START_CS              = 14,
  INF_START_IP              = 15,
  INF_START_EA              = 16,
  INF_START_SP              = 17,
  INF_MAIN                  = 18,
  INF_MIN_EA                = 19,
  INF_MAX_EA                = 20,
  INF_OMIN_EA               = 21,
  INF_OMAX_EA               = 22,
  INF_LOWOFF                = 23,
  INF_HIGHOFF               = 24,
  INF_MAXREF                = 25,
  INF_PRIVRANGE             = 26,
  INF_PRIVRANGE_START_EA    = 27,
  INF_PRIVRANGE_END_EA      = 28,
  INF_NETDELTA              = 29,
  INF_XREFNUM               = 30,
  INF_TYPE_XREFNUM          = 31,
  INF_REFCMTNUM             = 32,
  INF_XREFFLAG              = 33,
  INF_MAX_AUTONAME_LEN      = 34,
  INF_NAMETYPE              = 35,
  INF_SHORT_DEMNAMES        = 36,
  INF_LONG_DEMNAMES         = 37,
  INF_DEMNAMES              = 38,
  INF_LISTNAMES             = 39,
  INF_INDENT                = 40,
  INF_CMT_INDENT            = 41,
  INF_MARGIN                = 42,
  INF_LENXREF               = 43,
  INF_OUTFLAGS              = 44,
  INF_CMTFLG                = 45,
  INF_LIMITER               = 46,
  INF_BIN_PREFIX_SIZE       = 47,
  INF_PREFFLAG              = 48,
  INF_STRLIT_FLAGS          = 49,
  INF_STRLIT_BREAK          = 50,
  INF_STRLIT_ZEROES         = 51,
  INF_STRTYPE               = 52,
  INF_STRLIT_PREF           = 53,
  INF_STRLIT_SERNUM         = 54,
  INF_DATATYPES             = 55,
  INF_CC                    = 56,
  INF_CC_ID                 = 57,
  INF_CC_CM                 = 58,
  INF_CC_SIZE_I             = 59,
  INF_CC_SIZE_B             = 60,
  INF_CC_SIZE_E             = 61,
  INF_CC_DEFALIGN           = 62,
  INF_CC_SIZE_S             = 63,
  INF_CC_SIZE_L             = 64,
  INF_CC_SIZE_LL            = 65,
  INF_CC_SIZE_LDBL          = 66,
  INF_ABIBITS               = 67,
  INF_APPCALL_OPTIONS       = 68,

  // root node fields
  INF_FILE_FORMAT_NAME      = 69, ///< file format name for loader modules
  INF_GROUPS                = 70, ///< segment group information (see init_groups())
  INF_H_PATH                = 71, ///< C header path
  INF_C_MACROS              = 72, ///< C predefined macros
  INF_INCLUDE               = 73, ///< assembler include file name
  INF_DUALOP_GRAPH          = 74, ///< Graph text representation options
  INF_DUALOP_TEXT           = 75, ///< Text text representation options
  INF_MD5                   = 76, ///< MD5 of the input file
  INF_IDA_VERSION           = 77, ///< version of ida which created the database
  INF_STR_ENCODINGS         = 78, ///< a list of encodings for the program strings
  INF_DBG_BINPATHS          = 79, ///< unused (20 indexes)
  INF_SHA256                = 80, ///< SHA256 of the input file
  INF_ABINAME               = 81, ///< ABI name (processor specific)
  INF_ARCHIVE_PATH          = 82, ///< archive file path
  INF_PROBLEMS              = 83, ///< problem lists

  INF_SELECTORS             = 84, ///< 2..63 are for selector_t blob (see init_selectors())
  INF_NOTEPAD               = 85, ///< notepad blob, occupies 1000 indexes (1MB of text)
  INF_SRCDBG_PATHS          = 86, ///< source debug paths, occupies 20 indexes
  INF_SRCDBG_UNDESIRED      = 87, ///< user-closed source files, occupies 20 indexes
  INF_INITIAL_VERSION       = 88, ///< initial version of database
  INF_CTIME                 = 89, ///< database creation timestamp
  INF_ELAPSED               = 90, ///< seconds database stayed open
  INF_NOPENS                = 91, ///< how many times the database is opened
  INF_CRC32                 = 92, ///< input file crc32
  INF_IMAGEBASE             = 93, ///< image base
  INF_IDSNODE               = 94, ///< ids modnode id (for import_module)
  INF_FSIZE                 = 95, ///< input file size
  INF_OUTFILEENC            = 96, ///< output file encoding index
  INF_INPUT_FILE_PATH       = 97,
  INF_LAST = 98,
};
ssize_t getinf_buf(enum inftag_t tag, void *buf, size_t bufsize);

#if !defined(__LINUX__) || defined(__cplusplus)
typedef unsigned char  uchar;   ///< unsigned 8 bit value
typedef unsigned short ushort;  ///< unsigned 16 bit value
typedef unsigned int   uint;    ///< unsigned 32 bit value
#endif

typedef          char   int8;   ///< signed 8 bit value
typedef signed   char   sint8;  ///< signed 8 bit value
typedef unsigned char   uint8;  ///< unsigned 8 bit value
typedef          short  int16;  ///< signed 16 bit value
typedef unsigned short  uint16; ///< unsigned 16 bit value
typedef          int    int32;  ///< signed 32 bit value
typedef unsigned int    uint32; ///< unsigned 32 bit value

#ifdef __EA64__
  typedef uint64 ea_t;
  typedef uint64 sel_t;
  typedef uint64 asize_t;
  typedef int64 adiff_t;
  #define FMT_EA FMT_64
  #ifdef __GNUC__
    #define SVAL_MIN LLONG_MIN
    #define SVAL_MAX LLONG_MAX
  #else
    #define SVAL_MIN _I64_MIN
    #define SVAL_MAX _I64_MAX
  #endif
#else
  typedef uint32 ea_t;
  typedef uint32 sel_t;
  typedef uint32 asize_t;
  typedef int32 adiff_t;
  #define SVAL_MIN INT_MIN
  #define SVAL_MAX INT_MAX
  #define FMT_EA ""
#endif
bool set_segm_end(ea_t ea, ea_t newend, int flags);
bool set_segm_start(ea_t ea, ea_t newstart, int flags);
void put_bytes(ea_t ea, const void *buf, size_t size);
typedef void func_t;
func_t * get_func(ea_t ea);
bool append_func_tail(func_t *pfn, ea_t ea1, ea_t ea2);

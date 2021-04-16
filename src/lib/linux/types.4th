uint<64> 8 type: dev_t
uint<64> 8 type: ino_t
uint<32> 4 type: mode_t
uint<32> 4 type: nlink_t
uint<32> 4 type: uid_t
uint<32> 4 type: gid_t
uint<64> 8 type: off_t
uint<32> 4 type: blksize_t
uint<64> 8 type: blkcnt_t

struct: timespec
uint<32> 4 type: atime
uint<32> 4 type: atime-nsec
uint<32> 4 type: mtime
uint<32> 4 type: mtime-nsec
uint<32> 4 type: ctime

struct: Stat64
dev_t field: st_dev ( ID of device containing file )
uint<32> field: padding0
uint<32> field: _st_ino ( Inode number )
mode_t field: st_mode ( File type and mode )
nlink_t field: st_nlink ( Number of hard links )
uid_t field: st_uid ( User ID of owner )
gid_t field: st_gid ( Group ID of owner )
dev_t field: st_rdev ( Device ID if special file )
uint<32> field: padding1
off_t field: st_size ( Total size, in bytes )
blksize_t field: st_blksize ( Block size for filesystem I/O )
uint<64> field: st_ino
blkcnt_t field: st_blocks ( Number of 512B blocks allocated )
timespec field: st_atim ( Time of last access )
timespec field: st_mtim ( Time of last modification )
timespec field: st_ctim ( Time of last status change )

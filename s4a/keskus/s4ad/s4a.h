
/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

#ifndef _S4A_INCLUDED
# define _S4A_INCLUDED 1

#include <sys/queue.h>
#include <uthash.h>

typedef struct writer_struct {
	pid_t pid;
	int pipe;
	int status;
} Writer;

typedef struct struct_update {
	int ds;
	int file;
	char *updstr;
	char *tmplstr;
	UT_hash_handle hh;
} Update;

typedef struct cursor_buffer_struct {
	ssize_t len;
	ssize_t cursor;
	unsigned char *buf;
} CursorBuffer;

typedef struct message_buffer_struct {
	CursorBuffer len_b;
	CursorBuffer data_b;
} MsgBuffer;

typedef struct MsgQueueEntry {
	MsgBuffer mb;
	int socket;
	TAILQ_ENTRY(MsgQueueEntry) queue;   
} MsgQueueEntry;

TAILQ_HEAD(MsgQueue, MsgQueueEntry); 
typedef struct MsgQueue MsgQueue;

typedef struct struct_sid_mapping {
	int sid;
	int file;
	int ds;
	UT_hash_handle hh;
} SidMapping;

typedef struct struct_aggregator {
	int sid;
	float alerts;
	float intip;
	float extip;
	float srcdst;
	int detectors;
	UT_hash_handle hh;
} Aggregator;

typedef struct aggregator_ctx_struct {
	int keepalive;
	int serv_sock;
	int rq_maxlen;
	int wq_maxlen;
	Writer *writer;
	fd_set r_master;
	MsgQueue r_qu;
	fd_set w_master;
	MsgQueue w_qu;
	MsgQueueEntry *w_buf;
	SidMapping *sidtof;
	Aggregator *aggr;
} S4ACtx;


/*
 * Writer methods
 * */

void Writer_setup(Writer *cc, pid_t c_pid, int c_pipe);
Writer* Writer_new(pid_t c_pid, int c_pipe);
void Writer_free(Writer *cc);
Writer* Writer_fork();


/*
 * CursorBuffer methods
 * */

void CursorBuffer_init(CursorBuffer *cb);
void CursorBuffer_reinit(CursorBuffer *cb);
void CursorBuffer_reset(CursorBuffer *cb);
int CursorBuffer_read_prepared(CursorBuffer *cb);
void CursorBuffer_prepare_send(CursorBuffer *cb);
int CursorBuffer_prepare_read(CursorBuffer *cb, ssize_t new_sz);
size_t CursorBuffer_read(CursorBuffer *cb, unsigned char *t_buf, ssize_t t_len);
int CursorBuffer_readready(CursorBuffer *cb);
int CursorBuffer_cansend(CursorBuffer *cb);
int CursorBuffer_nothingtosend(CursorBuffer *cb);
int CursorBuffer_send(CursorBuffer *cb, int fd);

/*
 * MsgBuffer methods
 * */

void MsgBuffer_init(MsgBuffer *mb);
void MsgBuffer_reinit(MsgBuffer *mb);
void MsgBuffer_reset(MsgBuffer *mb);
int MsgBuffer_readready(MsgBuffer *mb);
int MsgBuffer_cansend(MsgBuffer *mb);
int MsgBuffer_nothingtosend(MsgBuffer *mb);
int MsgBuffer_read(MsgBuffer *mb, unsigned char *t_buf, ssize_t t_len, ssize_t max_len);
int MsgBuffer_send(MsgBuffer *mb, int fd);
int MsgBuffer_prepare_send(MsgBuffer *mb); 
void MsgBuffer_set(MsgBuffer *mb, unsigned char *t_buf, ssize_t t_len);

/*
 * MsgQueueEntry methods
 * */

MsgQueueEntry* MsgQueueEntry_new(int socket);
void MsgQueueEntry_free(MsgQueueEntry *mqe);
void MsgQueue_init(MsgQueue *head);
int MsgQueue_push(MsgQueue *head, MsgQueueEntry *elem);
int MsgQueue_empty(MsgQueue *head);
int MsgQueue_length(MsgQueue *head);
MsgQueueEntry* MsgQueue_pop(MsgQueue *head);
MsgQueueEntry* MsgQueue_peek(MsgQueue *head, int socket);
void MsgQueue_remove(MsgQueue *head, MsgQueueEntry *elem);
void MsgQueueEntry_set(MsgQueueEntry *mqe, unsigned char *buf, ssize_t buf_len);


/*
 * S4ACtx methods
 * */

void S4ACtx_init(S4ACtx *ctx);
Writer* S4ACtx_ensure_writer(S4ACtx *ctx);
void S4ACtx_check_writer_status(S4ACtx *ctx);
void S4ACtx_close_client(S4ACtx *ctx, int sock, MsgQueueEntry *mqe);
void S4ACtx_shutdown(S4ACtx *ctx);
void S4ACtx_log(S4ACtx *ctx);
void S4ACtx_load_config(S4ACtx *ctx);
Update* S4ACtx_compose_update(S4ACtx *ctx, int sid, float ds1, float ds2, float ds3, float ds4);
void S4ACtx_handle_update(S4ACtx *ctx, Update *upd, const char *detector);

#endif

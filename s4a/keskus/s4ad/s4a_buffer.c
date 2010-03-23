
/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

#include <stdlib.h>
#include <syslog.h>

#include <sys/types.h>
#include <unistd.h>
#include <errno.h>


#include "s4a.h"


/*
 * CursorBuffer methods
 * */

void CursorBuffer_init(CursorBuffer *cb)
{
	if (cb) {
		cb->len = 0;
		cb->cursor = 0;
		cb->buf = NULL;
	}
}

void CursorBuffer_reinit(CursorBuffer *cb)
{
	if (cb) {
		if (cb->buf) {
			free(cb->buf);
		}
		CursorBuffer_init(cb);
	}
}

void CursorBuffer_reset(CursorBuffer *cb)
{
	if (cb) {
		cb->len = 0;
		cb->cursor = 0;
	}
}

int CursorBuffer_read_prepared(CursorBuffer *cb) 
{
	if (cb) {
		return (cb->len > 0);
	}
	return 0;
}

void CursorBuffer_prepare_send(CursorBuffer *cb)
{
	if (cb) {
		cb->cursor = 0;
	}
}

// TODO save alloced length AND check for 0 allocs
int CursorBuffer_prepare_read(CursorBuffer *cb, ssize_t new_sz)
{
	int ret = -1;
	if (cb) {
		unsigned char *tmp = realloc(cb->buf, new_sz);
		if (tmp == NULL) {	
			goto error;
		}

		cb->buf = tmp;
		cb->cursor = 0;
		cb->len = new_sz;
	}
	else {
		goto error;
	}
	ret = 0;

error:

	return ret;
}

size_t CursorBuffer_read(CursorBuffer *cb, unsigned char *t_buf, ssize_t t_len)
{
	size_t ret = 0;
	while ((t_len > 0) && (cb->cursor < cb->len)) {
		cb->buf[cb->cursor] = t_buf[0];
		t_len--;
		ret++;
		cb->cursor++;
		t_buf = t_buf + 1;
	}
	return ret;
}

int CursorBuffer_readready(CursorBuffer *cb)
{
	if (cb) {
		return ((cb->len == cb->cursor) && (cb->len > 0));
	}
	syslog(LOG_NOTICE, "Anomaly in file (%s), line (%d)", __FILE__, __LINE__);
	return 0;
}

int CursorBuffer_cansend(CursorBuffer *cb) {
	if (cb) {
		return ((cb->cursor < cb->len) && (cb->len > 0));
	}
	syslog(LOG_NOTICE, "Anomaly in file (%s), line (%d)", __FILE__, __LINE__);
	return 0;
}

int CursorBuffer_nothingtosend(CursorBuffer *cb) {
	if (cb) {
		return ((cb->cursor == cb->len) || (cb->len == 0));
	}
	syslog(LOG_NOTICE, "Anomaly in file (%s), line (%d)", __FILE__, __LINE__);
	return 1; 
}

int CursorBuffer_send(CursorBuffer *cb, int fd)
{
	int ret = -1;
	if (cb) {
		if (cb->len > cb->cursor) {
			ssize_t ret = 0;
			ret = write(fd, cb->buf + cb->cursor, cb->len - cb->cursor);
			if (ret < 0) {
				if (errno != EAGAIN) {
					syslog(LOG_WARNING, "write %m");
					goto error;
				}
			}
			else {
				cb->cursor += ret;
				if (cb->cursor > cb->len) {
					syslog(LOG_NOTICE, "Anomaly in file (%s), line (%d)", __FILE__, __LINE__);
					goto error;
				}
			}
		}
	}
	else {
		syslog(LOG_NOTICE, "Anomaly in file (%s), line (%d)", __FILE__, __LINE__);
		goto error;
	}

	ret = 0;

error:

	return ret;
}


/*
 * MsgBuffer methods
 * */

void MsgBuffer_init(MsgBuffer *mb)
{
	if (mb) {
		CursorBuffer_init(&(mb->len_b));
		CursorBuffer_init(&(mb->data_b));
	}
}

void MsgBuffer_reinit(MsgBuffer *mb)
{
	if (mb) {
		CursorBuffer_reinit(&(mb->len_b));
		CursorBuffer_reinit(&(mb->data_b));
	}
}

void MsgBuffer_reset(MsgBuffer *mb)
{
	if (mb) {
		CursorBuffer_reset(&(mb->len_b));
		CursorBuffer_reset(&(mb->data_b));
	}
}

int MsgBuffer_readready(MsgBuffer *mb)
{
	if (mb) {
		return (CursorBuffer_readready(&(mb->len_b)) && CursorBuffer_readready(&(mb->data_b)));
	}
	syslog(LOG_NOTICE, "Anomaly in file (%s), line (%d)", __FILE__, __LINE__);
	return 0;
}

int MsgBuffer_cansend(MsgBuffer *mb) {
	if (mb) {
		if (CursorBuffer_cansend(&(mb->len_b)) && CursorBuffer_cansend(&(mb->data_b))) {
			return 1;
		}
		if (!CursorBuffer_cansend(&(mb->len_b))) {
			return CursorBuffer_cansend(&(mb->data_b));
		}
		return 0;
	}
	syslog(LOG_NOTICE, "Anomaly in file (%s), line (%d)", __FILE__, __LINE__);
	return 0;
}

int MsgBuffer_nothingtosend(MsgBuffer *mb) {
	if (mb) {
		if (CursorBuffer_nothingtosend(&(mb->len_b))) {
			return CursorBuffer_nothingtosend(&(mb->data_b));
		}
		return 0;
	}
	syslog(LOG_NOTICE, "Anomaly in file (%s), line (%d)", __FILE__, __LINE__);
	return 1;
}

void MsgBuffer_set(MsgBuffer *mb, unsigned char *t_buf, ssize_t t_len)
{
	if (mb) {
		CursorBuffer_prepare_read(&(mb->len_b), sizeof(ssize_t));
		CursorBuffer_read(&(mb->len_b), &t_len, sizeof(ssize_t));
		CursorBuffer_prepare_send(&(mb->len_b));
		mb->data_b.buf = t_buf;
		mb->data_b.len = t_len;
		CursorBuffer_prepare_send(&(mb->data_b));
		syslog(LOG_DEBUG, "Prepared to send %d bytes", t_len);
	}
}

int MsgBuffer_read(MsgBuffer *mb, unsigned char *t_buf, ssize_t t_len, ssize_t max_len)
{
	int ret = 0;
	if (mb) {
		if (!CursorBuffer_readready(&(mb->len_b))) {
			if (!CursorBuffer_read_prepared(&(mb->len_b))) {
				if (CursorBuffer_prepare_read(&(mb->len_b), sizeof(ssize_t)) == -1) {
					goto error;
				}
			}
			size_t tt = CursorBuffer_read(&(mb->len_b), t_buf, t_len);
			t_len -= tt;
			ret += tt;
			t_buf += tt;
		}

		if (CursorBuffer_readready(&(mb->len_b))) {
			if (!CursorBuffer_read_prepared(&(mb->data_b))) {
				ssize_t tt;
				memcpy(&tt, mb->len_b.buf, sizeof(ssize_t));
				if ((max_len > 0) && (tt > max_len)) {
					syslog(LOG_INFO, "Maximum allowed read length exceeded: %d > %d", tt, max_len);
					goto error;
				}
				if (CursorBuffer_prepare_read(&(mb->data_b), tt) == -1) {
					goto error;
				}
			}
			if (t_len > 0) {
				size_t tt = CursorBuffer_read(&(mb->data_b), t_buf, t_len);
				ret += tt;
			}
		}
		goto ok;
	}
	else {
		syslog(LOG_NOTICE, "Anomaly in file (%s), line (%d)", __FILE__, __LINE__);
		goto error;
	}

error:

	ret = -1;

ok:

	return ret;
}

int MsgBuffer_send(MsgBuffer *mb, int fd)
{
	int ret = -1;
	if (mb) {
		if (CursorBuffer_cansend(&(mb->len_b))) {
			if (CursorBuffer_send(&(mb->len_b), fd) == -1) {
				goto error;
			}
		}

		if (CursorBuffer_nothingtosend(&(mb->len_b))) {
			if (CursorBuffer_send(&(mb->data_b), fd) == -1) {
				goto error;
			}
		}
	}
	else {
		syslog(LOG_NOTICE, "Anomaly in file (%s), line (%d)", __FILE__, __LINE__);
		goto error;
	}

	ret = 0;

error:

	return ret;
}

int MsgBuffer_prepare_send(MsgBuffer *mb)  
{
	int ret = -1;
	if (mb) {
		CursorBuffer_prepare_send(&(mb->len_b));
		CursorBuffer_prepare_send(&(mb->data_b));
	}
	else {
		syslog(LOG_NOTICE, "Anomaly in file (%s), line (%d)", __FILE__, __LINE__);
		goto error;
	}

	ret = 0;

error:

	return ret;
}

/*
 * MsgQueueEntry methods
 * */

MsgQueueEntry* MsgQueueEntry_new(int socket)
{
	MsgQueueEntry *ret = NULL;
	ret = malloc(sizeof(MsgQueueEntry));
	if (ret) {
		MsgBuffer_init(&(ret->mb));
		ret->socket = socket;
	}
	return ret;
}

void MsgQueueEntry_free(MsgQueueEntry *mqe)
{
	if (mqe) {
		MsgBuffer_reinit(&(mqe->mb));
		free(mqe);
	}
}

void MsgQueueEntry_set(MsgQueueEntry *mqe, unsigned char *buf, ssize_t buf_len)
{
	if (mqe) {
		MsgBuffer_set(&(mqe->mb), buf, buf_len);	
	}
}

void MsgQueue_init(MsgQueue *head)
{
	if (head) {
		TAILQ_INIT(head);
	}
}

int MsgQueue_push(MsgQueue *head, MsgQueueEntry *elem)
{
	if (head && elem) {
		TAILQ_INSERT_HEAD(head, elem, queue);
		return 0;
	}
	return -1;
}

int MsgQueue_empty(MsgQueue *head) 
{
	if (head) {
		return TAILQ_EMPTY(head);
	}
	return 0;
}

int MsgQueue_length(MsgQueue *head)
{
	int ret = 0;
	MsgQueueEntry *iter = NULL;
	if (head) {
		TAILQ_FOREACH(iter, head, queue)
			ret++;
	}
	return ret;
}


MsgQueueEntry* MsgQueue_pop(MsgQueue *head)
{
	MsgQueueEntry *ret = NULL;
	if (!TAILQ_EMPTY(head)) {
		ret = TAILQ_LAST(head, MsgQueue);
		TAILQ_REMOVE(head, ret, queue);
	}
	return ret;
}

MsgQueueEntry* MsgQueue_peek(MsgQueue *head, int socket)
{
	MsgQueueEntry *ret = NULL;
	MsgQueueEntry *iter = NULL;

	if (head) {
		TAILQ_FOREACH(iter, head, queue)
			if (iter->socket == socket) {
				ret = iter;
				break;
			}
	}
	return ret;
}

void MsgQueue_remove(MsgQueue *head, MsgQueueEntry *elem)
{
	if (head && elem) {
		TAILQ_REMOVE(head, elem, queue);
	}
}


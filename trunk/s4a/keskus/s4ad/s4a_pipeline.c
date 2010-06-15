
/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

#include <stdlib.h>
#include <syslog.h>
#include <errno.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <signal.h>
#include <fcntl.h>
#include <pwd.h>

#include <rrd.h>

#include "s4a.h"

#define S4A_5_MINUTES 300
#define S4A_CONFIG "/var/www/etc/s4a-map"
#define BUF_SIZE 4096
#define SIGS_IN_RRD 100
#define DS_FOR_SIG 4 
#define UPDATE_LENGTH ((SIGS_IN_RRD * 8) + 2) 

#define S4A_MAX_RRD_FILES 100
#define S4A_SOCKET "/var/www/tmp/s4a"
#define S4A_LOCKFILE "/tmp/s4ad.lock"
#define S4A_DETECTORS "/usr/local/share/s4a/detectors"
#define S4A_MAX_PACKAGE 10000


#undef max
#define max(x, y) ((x) > (y) ? (x) : (y))

#undef min
#define min(x, y) ((x) < (y) ? (x) : (y))

/*
 * Global flags are modified in signal handlers.
 * The flags are examined, acted upon and set back to zero in select-loop.
 * We do not care about occuring races, because the baddest thing
 * That can happen is that we miss one of those signals
 * Due to the nature of behaviours associated to those signals we can allow ourselves that.
 *
 * If anything more complex is to be done with signals, possible race conditions must be taken 
 * into account
 * */

int is_set_reload_conf = 0;
int is_set_shutdown = 0;
int is_set_display_status = 0;

void writer_main(int p0, int p1);

int create_global_rrd (const char* rrd_name) {

	#define GLOBAL_RRD_COUNT 12
	
	int ret = -1;
	char **rrdarg = NULL;
	rrdarg = malloc(GLOBAL_RRD_COUNT * sizeof(char *));
	if (rrdarg == NULL) {
		goto error;
	}
	rrdarg[0] = strdup("create");	
	rrdarg[1] = strdup(rrd_name);
	rrdarg[2] = strdup("--start");
	rrdarg[3] = strdup("now - 700s");
	rrdarg[4] = strdup("RRA:AVERAGE:0.5:1:864");	
	rrdarg[5] = strdup("RRA:AVERAGE:0.5:12:168");	
	rrdarg[6] = strdup("RRA:AVERAGE:0.5:288:31");	
	rrdarg[7] = strdup("RRA:AVERAGE:0.5:2016:52");
	rrdarg[8] = strdup("DS:alerts:GAUGE:600:U:U"); 
	rrdarg[9] = strdup("DS:sigs:GAUGE:600:U:U"); 
	rrdarg[10] = strdup("DS:badratio:GAUGE:600:U:U"); 
	rrdarg[11] = strdup("DS:extip:GAUGE:600:U:U"); 

	int ii = 0;
	for (ii = 0; ii < GLOBAL_RRD_COUNT; ii++) {
		if (rrdarg[ii] == NULL) {
			goto error;
		}
	}

	ret = rrd_create(GLOBAL_RRD_COUNT, rrdarg);

error:

	if (rrdarg) {
		int ii = 0;
		for (ii = 0; ii < GLOBAL_RRD_COUNT; ii++) {
			free(rrdarg[ii]);
		}
		free(rrdarg);
	} 

	return ret;
}


int create_single_rrd (const char* rrd_name) {

	#define RRD_CREATE_COMMAND_FIELDS 8
	#define RRD_COUNT (RRD_CREATE_COMMAND_FIELDS + (DS_FOR_SIG * SIGS_IN_RRD)) 
	
	int ret = -1;
	char **rrdarg = NULL;
	rrdarg = malloc(RRD_COUNT * sizeof(char *));
	if (rrdarg == NULL) {
		goto error;
	}
	rrdarg[0] = strdup("create");	
	rrdarg[1] = strdup(rrd_name);
	rrdarg[2] = strdup("--start");
	rrdarg[3] = strdup("now - 700s");
	rrdarg[4] = strdup("RRA:AVERAGE:0.5:1:864");	
	rrdarg[5] = strdup("RRA:AVERAGE:0.5:12:168");	
	rrdarg[6] = strdup("RRA:AVERAGE:0.5:288:31");	
	rrdarg[7] = strdup("RRA:AVERAGE:0.5:2016:52");

	int ii = 0;
	for (ii = 0; ii < SIGS_IN_RRD; ii++) {
		int idx = (ii * DS_FOR_SIG) + RRD_CREATE_COMMAND_FIELDS;
		size_t buf_len = 0;
		
		rrdarg[idx + 0] = strdup("DS:alertsXXXX:GAUGE:600:U:U");
		if (rrdarg[idx + 0]) {
			buf_len = strlen(rrdarg[idx + 0]) + 1;
			snprintf(rrdarg[idx + 0], buf_len, "DS:alerts%d:GAUGE:600:U:U", ii);
		}	

		rrdarg[idx + 1] = strdup("DS:intipXXXX:GAUGE:600:U:U");	
		if (rrdarg[idx + 1]) {
			buf_len = strlen(rrdarg[idx + 1]) + 1;
			snprintf(rrdarg[idx + 1], buf_len, "DS:intip%d:GAUGE:600:U:U", ii);
		}
	

		rrdarg[idx + 2] = strdup("DS:extipXXXX:GAUGE:600:U:U");
		if (rrdarg[idx + 2]) {
			buf_len = strlen(rrdarg[idx + 2]) + 1;
			snprintf(rrdarg[idx + 2], buf_len, "DS:extip%d:GAUGE:600:U:U", ii);
		}
	
		rrdarg[idx + 3] = strdup("DS:srcdstXXXX:GAUGE:600:U:U");
		if (rrdarg[idx + 3]) {
			buf_len = strlen(rrdarg[idx + 3]) + 1;
			snprintf(rrdarg[idx + 3], buf_len, "DS:srcdst%d:GAUGE:600:U:U", ii);
		}
	}

	for (ii = 0; ii < RRD_COUNT; ii++) {
		if (rrdarg[ii] == NULL) {
			goto error;
		}
	}

	ret = rrd_create(RRD_COUNT, rrdarg);

error:

	if (rrdarg) {
		int ii = 0;
		for (ii = 0; ii < RRD_COUNT; ii++) {
			free(rrdarg[ii]);
		}
		free(rrdarg);
	} 


	return ret;
}


time_t last_update_time(const char* rrd_name) {
	#define RRD_LASTUPDATE_COMMAND_FIELDS 2

	time_t ret = -1;

	char **rrdupd00 = NULL;
	rrdupd00 = (char**)malloc(RRD_LASTUPDATE_COMMAND_FIELDS * sizeof(char *));
	if (rrdupd00 == NULL) {
		goto end;
	}
	rrdupd00[0] = strdup("lastupdate");
	rrdupd00[1] = strdup(rrd_name);
	 
	int ii = 0;
	for (ii = 0; ii < RRD_LASTUPDATE_COMMAND_FIELDS; ii++) {
		if (rrdupd00[ii] == NULL) {
			goto end;
		}
	}
			
	ret = rrd_last(RRD_LASTUPDATE_COMMAND_FIELDS, rrdupd00);

end:
	if (rrdupd00) {
		for (ii = 0; ii < RRD_LASTUPDATE_COMMAND_FIELDS; ii++) {
			free(rrdupd00[ii]);
		}  
	 
		free(rrdupd00);
	}
		
	return ret;
}

int do_update(const char* rrd_name, const char* rrd_update_str) {
	#define RRD_UPDATE_COMMAND_FIELDS 3

	int ret = -1;

	char **rrdupd00 = NULL;
	rrdupd00 = (char**)malloc(RRD_UPDATE_COMMAND_FIELDS * sizeof(char *));
	if (rrdupd00 == NULL) {
		goto end;
	}
	rrdupd00[0] = strdup("update");
	rrdupd00[1] = strdup(rrd_name);
	rrdupd00[2] = strdup(rrd_update_str);

	int ii = 0;
	for (ii = 0; ii < RRD_UPDATE_COMMAND_FIELDS; ii++) {
		if (rrdupd00[ii] == NULL) {
			goto end;
		}
	}

	ret = rrd_update(RRD_UPDATE_COMMAND_FIELDS, rrdupd00);

end:
	if (rrdupd00) {
		for (ii = 0; ii < RRD_UPDATE_COMMAND_FIELDS; ii++) {
			free(rrdupd00[ii]);
		}

		free(rrdupd00);
	}

	return ret;
}

int update_zeros (const char* rrd_name, time_t now, int zeros) {
	int ret = -1;
	char timestr[11];
	snprintf(timestr, 11, "%d", now);

	int emptylen = 0;
	char* empty = NULL;

	emptylen = 2 * zeros;
	emptylen += 10; // time_t in str
	emptylen += 1; // \0

	empty = malloc(emptylen);
	if (empty == NULL) {
		goto end;
	}

	memset(empty, 0, emptylen);
	strlcat(empty, timestr, emptylen);
	while (zeros) {
		strlcat(empty, ":0", emptylen);
		zeros--;
	}

	ret = do_update(rrd_name, empty);

end:
	if (empty) {
		free(empty);
	}

	return ret;
}


int store_single_rrd (const char *type, const char* rrd_name, const char* rrd_update_str) {
 
	int ret = -1;
	struct stat buffer;
	if (stat(rrd_name, &buffer) == -1) {
		if (errno != ENOENT) {
			goto end;
		}
		if (strcmp("global", type) == 0) {
			ret = create_global_rrd(rrd_name);
		}
		else {
			ret = create_single_rrd(rrd_name);
		}
		if (ret != 0) {
			goto end;
		}
	}

	time_t now = time(NULL);
	if (now == -1) {
		goto end;
	}

	time_t last_upd = last_update_time(rrd_name);
	if (last_upd == -1) {
		goto end;
	}

	if (now - last_upd >  S4A_5_MINUTES) {
		int zeros = 0;
		if (strcmp("global", type) == 0) {
			zeros = 4;
		}
		else {
			zeros = SIGS_IN_RRD * DS_FOR_SIG;
		}

		now -= S4A_5_MINUTES;
		if (now - last_upd > S4A_5_MINUTES) {
			now -= S4A_5_MINUTES;	
			ret = update_zeros(rrd_name, now, zeros);
			if (ret == -1) {
				goto end;
			}
			now += S4A_5_MINUTES;
		}

		ret = update_zeros(rrd_name, now, zeros);
		if (ret == -1) {
			goto end;
		}
	}

	ret = do_update(rrd_name, rrd_update_str);

end:

	return ret;
}

int ensure_directory(const char* directory, struct passwd *passwd) {
	int ret = -1;
	if (directory) {
		struct stat buffer;
		int status = stat(directory, &buffer);
		if (status != 0) {
			if (mkdir(directory, S_IRWXU) == -1) { 
				goto error;
			}
			if (passwd) {
				if (chown(directory, passwd->pw_uid, passwd->pw_gid) == -1) {
					goto error;
				}
			}
		}
		ret = 0;
	}

error:

	return ret;
}

/*
 * Update methods
 * */

Update* Update_new()
{
	Update *ret = NULL;
	ret = malloc(sizeof(Update));
	if (ret) {
		ret->ds = 0;
		ret->file = 0;
		ret->updstr = NULL;
//		ret->tmplstr = NULL;
	}
	return ret;	
}

void Update_free(Update *upd)
{
	if (upd) {
		free(upd->updstr);
//		free(upd->tmplstr);
		free(upd);
	}
}


/*
 * Writer methods
 * */

void Writer_setup(Writer *cc, pid_t c_pid, int c_pipe)
{
	if (cc) {
		cc->pid = c_pid;
		cc->pipe = c_pipe;
		cc->status = 0;
	}
}

Writer* Writer_new(pid_t c_pid, int c_pipe)
{
	Writer *ret = NULL;
	ret = malloc(sizeof(Writer));
	if (ret) {
		Writer_setup(ret, c_pid, c_pipe);
	}
	return ret;
}

void Writer_free(Writer *cc)
{
	if (cc) {
		free(cc);
	}
}

Writer* Writer_fork() 
{
	pid_t pid = 1;
	int my_pipe[2];

	if (pipe(my_pipe) == -1) {
		return NULL;
	}

	if ((pid = fork()) == -1) {
		return NULL;
	}

	if (pid) {
		if (close(my_pipe[0]) == -1) {
			return NULL;
		}
		return Writer_new(pid, my_pipe[1]);
	}
	else {
		writer_main(my_pipe[0], my_pipe[1]);
	}
	return NULL;
}

/*
 * Aggregator methods
 * */

Aggregator* Aggregator_find(S4ACtx *ctx, int sid)
{
	Aggregator *ret = NULL;
	if (ctx) {
		HASH_FIND_INT(ctx->aggr, &sid, ret);
	}
	return ret;
}

void Aggregator_add(S4ACtx *ctx, int sid, float ds1, float ds2, float ds3, float ds4)
{
	if (ctx) {
		Aggregator *add = NULL;
		add = malloc(sizeof(Aggregator)); // TODO
		if (add) {
			add->sid = sid;
			add->alerts = ds1;
			add->intip = ds2;
			add->extip = ds3;
			add->srcdst = ds4;
			add->detectors = 1;
			HASH_ADD_INT(ctx->aggr, sid, add);	
		}
	}
}

void Aggregator_destroy(S4ACtx *ctx)
{
	Aggregator *current = NULL;
	if (ctx) {
		while (ctx->aggr) {
			current = ctx->aggr;
			HASH_DEL(ctx->aggr, current);
			free(current);
		}
	}
}

void Aggregator_update(S4ACtx *ctx, int sid, float ds1, float ds2, float ds3, float ds4)
{
	if (ctx) {
		Aggregator *agg = Aggregator_find(ctx, sid);
		if (agg) {
			agg->alerts += ds1;
			agg->intip += ds2;
			agg->extip += ds3;
			agg->srcdst += ds4;
			agg->detectors += 1;
		}
		else {
			Aggregator_add(ctx, sid, ds1, ds2, ds3, ds4);
		}
	}
}

void Aggregator_aggregate(S4ACtx *ctx)
{
	if (ctx) {
		Aggregator *it = NULL;
		for (it = ctx->aggr; it != NULL; it = it->hh.next) {
			it->alerts = it->alerts / it->detectors;
			it->intip = it->intip / it->detectors;
			it->extip = it->extip / it->detectors;
			it->srcdst = it->srcdst / it->detectors;
		}
	}
}

void Aggregator_pushtoqueue(S4ACtx *ctx)
{
	Update* files[S4A_MAX_RRD_FILES]; // TODO
	int ii = 0;
	for (ii = 0; ii < S4A_MAX_RRD_FILES; ii++) {
		files[ii] = NULL;
	}

	if (ctx) {
		while (ctx->aggr) {
			Aggregator *current = ctx->aggr;
			HASH_DEL(ctx->aggr, current);
			Update *upd = S4ACtx_compose_update(ctx, current->sid, 
							current->alerts, 
							current->intip, 
							current->extip, 
							current->srcdst); 
			if (upd) {
				syslog(LOG_DEBUG, "Update: file: %d, ds: %d, str: %s", upd->file, upd->ds, upd->updstr);
				Update *tst = NULL;
				HASH_FIND_INT(files[upd->file], &(upd->ds), tst);
				if (tst == NULL) {
					HASH_ADD_INT(files[upd->file], ds, upd);
				}
			}

			free(current);
		}

		for (ii = 0; ii < S4A_MAX_RRD_FILES; ii++) {
			S4ACtx_handle_update(ctx, files[ii], "s4a-detector");
			Update *it = NULL;
			while (files[ii]) {
				it = files[ii];
				HASH_DEL(files[ii], it);
				Update_free(it);
			}
		}
	}
}

/*
 * SidMapping methods
 * */

SidMapping* SidMapping_find(S4ACtx *ctx, int sid)
{
	SidMapping *ret = NULL;
	if (ctx) {
		HASH_FIND_INT(ctx->sidtof, &sid, ret);
	}
	return ret;
}

void SidMapping_add(S4ACtx *ctx, int sid, int ff, int ds)
{
	if (ctx) {
		SidMapping *add = NULL;
		add = malloc(sizeof(SidMapping)); // TODO
		if (add) {
			add->sid = sid;
			add->file = ff;
			add->ds = ds;
			HASH_ADD_INT(ctx->sidtof, sid, add);	
		}
	}
}


void SidMapping_destroy(S4ACtx *ctx)
{
	SidMapping *current = NULL;
	if (ctx) {
		while (ctx->sidtof) {
			current = ctx->sidtof;
			HASH_DEL(ctx->sidtof, current);
			free(current);
		}
	}
}



/*
 * S4ACtx methods
 * */

void S4ACtx_init(S4ACtx *ctx)
{
	if (ctx) {
		ctx->keepalive = 1;
		ctx->writer = NULL;
		FD_ZERO(&(ctx->r_master));
		MsgQueue_init(&(ctx->r_qu));
		FD_ZERO(&(ctx->w_master));
		MsgQueue_init(&(ctx->w_qu));
		ctx->w_buf = NULL;
		ctx->sidtof = NULL;
		ctx->aggr = NULL; 

		ctx->serv_sock = -1;
		ctx->rq_maxlen = 0;
		ctx->wq_maxlen = 0;
	}
} 

Writer* S4ACtx_ensure_writer(S4ACtx *ctx)
{
	Writer *ret = NULL;

	if (ctx == NULL) {
		goto error;
	}

	if (ctx->writer != NULL) {
		goto ok;
	}

	ctx->writer = Writer_fork();
	if (ctx->writer == NULL) {
		goto error;
	}
	if (fcntl(ctx->writer->pipe, F_SETFL, O_NONBLOCK) == -1) {
		goto error;
	}

	FD_ZERO(&(ctx->w_master));

ok:

	ret = ctx->writer;

error:

	return ret;
}

void S4ACtx_check_writer_status(S4ACtx *ctx)
{
	if (ctx && ctx->writer) {
		pid_t w_res = waitpid(ctx->writer->pid, &(ctx->writer->status), WNOHANG);
		if (w_res != 0) {
			if (w_res == -1) {
				syslog(LOG_ERR, "waitpid %m");
			}
			else {
				if (w_res != ctx->writer->pid) {
					syslog(LOG_ERR, "Unexpected return value from waitpid (%d != %d)", w_res, ctx->writer->pid);
				}
				else {
					syslog(LOG_INFO, "Writing process status field (%d)", ctx->writer->status);
					if (WIFEXITED(ctx->writer->status)) {
						syslog(LOG_INFO, "Writing process exited with status (%d)", WEXITSTATUS(ctx->writer->status));
					}
					if (WIFSIGNALED(ctx->writer->status)) {
						syslog(LOG_INFO, "Writing process was killed by signal (%d)", WTERMSIG(ctx->writer->status));
					}
				}
			}
			if (close(ctx->writer->pipe) == -1) {
				syslog(LOG_WARNING, "close %m");
			}
			Writer_free(ctx->writer);
			ctx->writer = NULL;
			FD_ZERO(&(ctx->w_master));

			//Clear half-sent buffer
			if (ctx->w_buf) {
				syslog(LOG_ERR, "Writing process died, some data is gone for good...");
				MsgQueueEntry_free(ctx->w_buf);
				ctx->w_buf = NULL;
			}
		}
	}
}

void S4ACtx_close_client(S4ACtx *ctx, int sock, MsgQueueEntry *mqe)
{
	if (ctx) {
		if (close(sock) == -1) {
			syslog(LOG_ERR, "close %m");
		}
		FD_CLR(sock, &(ctx->r_master));
		if (mqe) {
			MsgQueue_remove(&(ctx->r_qu), mqe);
			MsgQueueEntry_free(mqe);
		}
	}
}

void S4ACtx_shutdown(S4ACtx *ctx)
{
	if (ctx) {
		syslog(LOG_INFO, "Shutting down");
		ctx->keepalive = 0;
		if (shutdown(ctx->serv_sock, SHUT_RDWR) == -1) {
			syslog(LOG_ERR, "shutdown (%s) (%m)", S4A_SOCKET);
		}
		if (close(ctx->serv_sock) == -1) {
			syslog(LOG_ERR, "close (%s) (%m)", S4A_SOCKET);
		}
		if (unlink(S4A_SOCKET) == -1) {
			syslog(LOG_ERR, "unlink (%s) (%m)", S4A_SOCKET);
		}
		SidMapping_destroy(ctx);
		Aggregator_destroy(ctx);		
		closelog();
	}
}

void S4ACtx_log(S4ACtx *ctx)
{
	if (ctx) {
		if (ctx->writer) {
			syslog(LOG_INFO, "Writing process pid: %d", ctx->writer->pid);
		}
		else {
			syslog(LOG_INFO, "Writing process not created");
		}

		syslog(LOG_INFO, "Read queue current length: %d", MsgQueue_length(&(ctx->r_qu)));
		syslog(LOG_INFO, "Read queue max length: %d", ctx->rq_maxlen);
		syslog(LOG_INFO, "Write queue current length: %d", MsgQueue_length(&(ctx->w_qu)));
		syslog(LOG_INFO, "Write queue max length: %d", ctx->wq_maxlen);

		if (ctx->w_buf) {
			syslog(LOG_INFO, "One write is active");
		}
		else {
			syslog(LOG_INFO, "No active write");
		}
	}
	else {
		syslog(LOG_INFO, "Context not present");
	}
}

int S4ACtx_handle_conf_line(S4ACtx *ctx, char *line)
{
	int ret = -1; 
	if (ctx && line && strlen(line)) {
	
		char *data[3];
	
		int ii = 0;
		for (ii = 0; ii < 3 ; ii++) {
			data[ii] = NULL;
		}

		char *inp = line;
	
		ii = 0;
		while (ii < 3) {
			data[ii] = strsep(&inp, "\t");
			if (data[ii] == NULL) {
				break;
			}
			ii++;
		}

		if (ii == 3) {
			int sid = atoi(data[0]);
			int file = atoi(data[1]);
			int ds = atoi(data[2]);
			if (SidMapping_find(ctx, sid) == NULL) {
				SidMapping_add(ctx, sid, file, ds);
				ret = 0;
			}
		}
	}
	return ret;
}


void S4ACtx_load_config(S4ACtx *ctx)
{
	if (ctx) {
		FILE *file = 0;
		if ((file = fopen(S4A_CONFIG, "r")) != NULL) {
			int count = 0;
			syslog(LOG_INFO, "Loading %s", S4A_CONFIG);
			char buf[BUF_SIZE];
			while (feof(file) == 0) {
				if (fgets(buf, BUF_SIZE, file)) {
					if (S4ACtx_handle_conf_line(ctx, buf) == -1) {
						syslog(LOG_WARNING, "Invalid conf-line: %s", buf);
					}
					else {
						count++;
					}
				}
			}
			syslog(LOG_INFO, "Successfully loaded %d conf-lines", count);
			fclose(file);
		}
		else {
			syslog(LOG_ERR, "opening file (%s) (%m)", S4A_CONFIG);
		}
	}
}

void S4ACtx_handle_update(S4ACtx *ctx, Update *upd, const char *detector)
{

// XXX: Siin funktsioonis peame lahti saama template'ist ja peame koostama korrektse ::::::::::::::::: stringi

	if (ctx && upd) {
		syslog(LOG_DEBUG, "Detector: %s %d updates to file %d", detector, HASH_COUNT(upd), upd->file);

		char fnum[3];
		memset(fnum, 0, 3);
		snprintf(fnum, 3, "%d", upd->file); //TODO	

		ssize_t msg_len = 0;
		Update *it = NULL;
		for (it = upd; it != NULL; it = it->hh.next) {
			msg_len += strlen(it->updstr); 
//			msg_len += strlen(it->tmplstr);
		}

		int unkn = SIGS_IN_RRD - HASH_COUNT(upd);
		msg_len += (unkn * DS_FOR_SIG * 2);

//		Update *tst = NULL;
//		HASH_FIND_INT(files[upd->file], &(upd->ds), tst);

		msg_len += (strlen(detector) + 1);
		msg_len += (strlen(fnum) + 1);
		msg_len += (1 + 1);

		char *msg = malloc(msg_len);
		if (msg) {
			memset(msg, 0, msg_len);
			strlcat(msg, detector, msg_len);
			strlcat(msg, "\t", msg_len);
			strlcat(msg, fnum, msg_len);				
			//strlcat(msg, "\t", msg_len);
			//for (it = upd; it != NULL; it = it->hh.next) {
			//	strlcat(msg, it->tmplstr, msg_len);
			//}
			//msg[strlen(msg) - 1] = '\0';

			strlcat(msg, "\tN", msg_len);

			int ds = 0;
			for (ds = 0; ds < SIGS_IN_RRD; ds++) {
				Update *tst = NULL;
				HASH_FIND_INT(upd, &ds, tst);
				if (tst) {
					strlcat(msg, tst->updstr, msg_len);
				}
				else {
					strlcat(msg, ":0:0:0:0", msg_len);
				}
			}

//			for (it = upd; it != NULL; it = it->hh.next) {
//				strlcat(msg, it->updstr, msg_len);
//			}

			MsgQueueEntry *ee = MsgQueueEntry_new(-1);
			MsgQueueEntry_set(ee, msg, msg_len);
			if (MsgQueue_push(&(ctx->w_qu), ee) == -1) {
				syslog(LOG_ERR, "Error adding output to write-queue");
			}
		}
	}
}

Update* S4ACtx_compose_update(S4ACtx *ctx, int sid, float ds1, float ds2, float ds3, float ds4)
{
	Update *ret = NULL;

	if (ctx) {
		SidMapping *sm = SidMapping_find(ctx, sid);
		if (sm) {
			char *tmpupd = NULL;
//			char *tmptmpl = NULL;

			ret = Update_new();
			if (ret) {
				ret->file = sm->file;
				ret->ds = sm->ds;					
				if (asprintf(&tmpupd, ":%.f:%.2f:%.f:%.f", ds1, ds2, ds3, ds4) == -1) {
					goto error;
				}
				ret->updstr = tmpupd;

// XXX: Update template väli on liigne
//				if (asprintf(&tmptmpl, "alerts%d:intip%d:extip%d:srcdst%d:", sm->ds, sm->ds, sm->ds, sm->ds) == -1) {
//					goto error;
//				}
//				ret->tmplstr = tmptmpl;
				goto ok;
			}
		}
	}


error:

	if (ret) {
		Update_free(ret);
		ret = NULL;
	}

ok:
	return ret;
}

void sig_conf(int sigraised)
{
	is_set_reload_conf = 1;
}

void sig_die(int sigraised)
{
	is_set_shutdown = 1;
}

void sig_log(int sigraised)
{
	is_set_display_status = 1;
}

void setup_signals()
{
	signal(SIGHUP, sig_conf);
	signal(SIGINT, sig_die);
	signal(SIGQUIT, sig_die);
	signal(SIGILL, SIG_DFL);	// create core image   illegal instruction
	signal(SIGTRAP, SIG_DFL);	// create core image   trace trap
	signal(SIGABRT, SIG_DFL);	// create core image   abort(3) call (formerly SIGIOT)
	signal(SIGEMT, SIG_DFL);	// create core image   emulate instruction executed
	signal(SIGFPE, SIG_DFL);	// create core image   floating-point exception
	// SIGKILL cannot be caught or ignored    terminate process   kill program
	signal(SIGBUS, SIG_DFL);	// create core image   bus error
	signal(SIGSEGV, SIG_DFL);	// create core image   segmentation violation
	signal(SIGSYS, SIG_DFL);	// create core image   system call given invalid argument
	signal(SIGPIPE, SIG_IGN);
	signal(SIGALRM, SIG_IGN);
	signal(SIGTERM, sig_die);
	signal(SIGURG, SIG_DFL);	// discard signal      urgent condition present on socket
	// SIGSTOP cannot be caught or ignored    stop process	stop (cannot be caught or ignored)
	signal(SIGTSTP, SIG_DFL);	// stop process	stop signal generated from keyboard
	signal(SIGCONT, SIG_DFL);	// discard signal      continue after stop
	signal(SIGCHLD, SIG_IGN);
	signal(SIGTTIN, SIG_DFL);	// stop process	background read attempted from control terminal
	signal(SIGTTOU, SIG_DFL);	// stop process	background write attempted to control terminal
	signal(SIGIO, SIG_DFL);		// discard signal      I/O is possible on a descriptor (see fcntl(2))
	signal(SIGXCPU, SIG_DFL);	// terminate process   CPU time limit exceeded (see setrlimit(2))
	signal(SIGXFSZ, SIG_DFL);	// terminate process   file size limit exceeded (see setrlimit(2))
	signal(SIGVTALRM, SIG_DFL);	// terminate process   virtual time alarm (see setitimer(2))
	signal(SIGPROF, SIG_DFL);	// terminate process   profiling timer alarm (see setitimer(2))
	signal(SIGWINCH, SIG_DFL);	// discard signal      window size change
	signal(SIGINFO, SIG_DFL);	// discard signal      status request from keyboard
	signal(SIGUSR1, sig_log);
	signal(SIGUSR2, SIG_IGN);
}

int setup_socket(struct passwd *passwd)
{
	int ret = -1;
	struct sockaddr_un local;
	ssize_t len = 0;
	int sock = socket(AF_UNIX, SOCK_STREAM, 0);
	if (sock < 0) {
		goto error;
	}

	if (fcntl(sock, F_SETFL, O_NONBLOCK) == -1) {
		goto error;
	}

	local.sun_family = AF_UNIX;
	strlcpy(local.sun_path, S4A_SOCKET, 104); // <sys/un.h>
	local.sun_len = strlen(local.sun_path) + 1; 
	if (unlink(local.sun_path) == -1) {
		if (errno != ENOENT) {
			goto error;
		}
	}

	len = local.sun_len + sizeof(local.sun_len) + sizeof(local.sun_family);
	if (bind(sock, (struct sockaddr *)&local, len) == -1) {
		goto error;
	}

	if (listen(sock, 25) == -1) {
		goto error;
	}

	if (passwd) {
		if (chown(local.sun_path, passwd->pw_uid, -1) == -1) {
			goto error;
		}
	}

	ret = sock;

error:

	return ret;
}


char* handle_global_line(S4ACtx *ctx, char *detector, char *line)
{
	#define S4A_XML_RPC_MSG_LEN 5

	char *ret = NULL;
	
	char *data[S4A_XML_RPC_MSG_LEN];
	int ii = 0;
	for (ii = 0; ii < S4A_XML_RPC_MSG_LEN; ii++) {
		data[ii] = NULL;
	}

	char *inp = line;
	ii = 0;
	for (ii = 0; ii < S4A_XML_RPC_MSG_LEN; ii++) {
		data[ii] = strsep(&inp, "\t");
		if (data[ii] == NULL) {
			goto error;
		}
	}

	ssize_t msg_len = 0;

	msg_len += strlen(detector) + 1;
	msg_len += strlen("global") + 1;
	msg_len += strlen("N::::") + 1 +
			strlen(data[1]) + strlen(data[2]) + 
			strlen(data[3]) + strlen(data[4]);

	char *msg = malloc(msg_len);
	if (msg) {
		memset(msg, 0, msg_len);
		strlcat(msg, detector, msg_len);
		strlcat(msg, "\t", msg_len);
		strlcat(msg, "global", msg_len);				
		strlcat(msg, "\t", msg_len);
		strlcat(msg, "N", msg_len);
		strlcat(msg, ":", msg_len);
		strlcat(msg, data[1], msg_len);
		strlcat(msg, ":", msg_len);
		strlcat(msg, data[2], msg_len);
		strlcat(msg, ":", msg_len);
		strlcat(msg, data[3], msg_len);
		strlcat(msg, ":", msg_len);
		strlcat(msg, data[4], msg_len);
		ret = msg;
	}

error:

	return ret;
}

Update* handle_sid_line(S4ACtx *ctx, char *line)
{
	#define S4A_XML_RPC_MSG_LEN 5
	
	Update *ret = NULL;

	char *data[S4A_XML_RPC_MSG_LEN];
	int ii = 0;
	for (ii = 0; ii < S4A_XML_RPC_MSG_LEN; ii++) {
		data[ii] = NULL;
	}

	char *inp = line;
	ii = 0;
	for (ii = 0; ii < S4A_XML_RPC_MSG_LEN; ii++) {
		data[ii] = strsep(&inp, "\t");
		if (data[ii] == NULL) {
			goto error;
		}
	}

	inp = data[0];
	char *strgen = strsep(&inp, ":");
	char *strsid = strsep(&inp, ":");

	if ((strcmp("1", strgen) == 0) && strsid && strlen(strsid)) {
		int sid = atoi(strsid);
		float ds1 = strtof(data[1], NULL);
		float ds2 = strtof(data[2], NULL);
		float ds3 = strtof(data[3], NULL);
		float ds4 = strtof(data[4], NULL);

		ret = S4ACtx_compose_update(ctx, sid, ds1, ds2, ds3, ds4); 
		if (ret) {
			Aggregator_update(ctx, sid, ds1, ds2, ds3, ds4);
		}
	}
	else {
		syslog(LOG_NOTICE, "Snort alert-generators are not taken into account currently: %s", strgen);
	}

error:

	return ret;
}

void S4ACtx_handle(S4ACtx *ctx, MsgQueueEntry *elem)
{

	Update* files[S4A_MAX_RRD_FILES]; // TODO
	int ii = 0;
	for (ii = 0; ii < S4A_MAX_RRD_FILES; ii++) {
		files[ii] = NULL;
	}

	if (ctx && elem) {
		MsgBuffer *mb = &(elem->mb);
		char *inp = mb->data_b.buf;
		char *shortname = strsep(&inp, "\n");
		char *line = NULL;
		do {
			line = strsep(&inp, "\n");
			if (line && strlen(line)) {
				if (strncmp("global", line, strlen("global")) != 0) {
					Update *upd = handle_sid_line(ctx, line);
					if (upd) {
						syslog(LOG_DEBUG, "Update: file: %d, ds: %d, str: %s", upd->file, upd->ds, upd->updstr);
						Update *tst = NULL;
						HASH_FIND_INT(files[upd->file], &(upd->ds), tst);
						if (tst == NULL) {
							HASH_ADD_INT(files[upd->file], ds, upd);
						}
						else {
							syslog(LOG_WARNING, "Datasource %d was sent twice by %s", upd->ds, shortname);
						}
					}
				}
				else {
					char *g_msg = handle_global_line(ctx, shortname, line);
					if (g_msg) {
						syslog(LOG_DEBUG, "%s", g_msg);
						MsgQueueEntry *ee = MsgQueueEntry_new(-1);
						MsgQueueEntry_set(ee, g_msg, strlen(g_msg) + 1);
						if (MsgQueue_push(&(ctx->w_qu), ee) == -1) {
							syslog(LOG_ERR, "Error adding output to write-queue");
						}
					}
				}
			}
		} while (line != NULL);

		for (ii = 0; ii < S4A_MAX_RRD_FILES; ii++) {
			S4ACtx_handle_update(ctx, files[ii], shortname);
			Update *it = NULL;
			while (files[ii]) {
				it = files[ii];
				HASH_DEL(files[ii], it);
				Update_free(it);
			}
		}
	}
}

void lock_or_exit()
{
	int lfp = open(S4A_LOCKFILE, O_RDWR | O_CREAT, 0640);
	if (lfp == -1) {
		syslog(LOG_ERR, "Couldn't open (%s) (%m)", S4A_LOCKFILE);
		exit(1);
	}
	if (lockf(lfp, F_TLOCK, 0) == -1) {
		syslog(LOG_ERR, "Couldn't lock (%s) (%m)", S4A_LOCKFILE);
		exit(1);
	}
	char str[40];
	snprintf(str, 40, "%d\n", getpid());
	ssize_t ret = write(lfp, str, strlen(str));
	if ((ret == -1) || (ret != strlen(str))) {
		syslog(LOG_ERR, "Couldn't write pid to (%s) (%m)", S4A_LOCKFILE);
		exit(1);
	}
}

void s4a_main() {

	unsigned char data[BUF_SIZE];
	S4ACtx ctx;
	S4ACtx_init(&ctx);

	umask(S_IRGRP | S_IXGRP | S_IRWXO); // Group may gain right to write

	openlog("s4a-aggregator", LOG_PID, LOG_LOCAL3);
	if (daemon(1, 0) == -1) {
		syslog(LOG_ERR, "daemon %m");
		exit(1);
	}

	lock_or_exit();
	syslog(LOG_INFO, "Started");

	S4ACtx_load_config(&ctx);

	setup_signals();

	struct passwd *passwd = getpwnam("_s4ad");
	if (passwd == NULL) {
		syslog(LOG_WARNING, "getpwnam for _s4ad %m");
		exit(1);
	}

	if (ensure_directory(S4A_DETECTORS, passwd) == -1) {
		syslog(LOG_ERR, "Unable to create directory (%s) (%m)", S4A_DETECTORS);
		exit(1);
	}

	ctx.serv_sock = setup_socket(passwd);
	if (ctx.serv_sock == -1) {
		syslog(LOG_ERR, "setup_socket (%s) (%m)", S4A_SOCKET);
		exit(1);
	}

	if ((setgid(passwd->pw_gid) == -1) || (setuid(passwd->pw_uid) == -1)) {
		syslog(LOG_WARNING, "setgid/setuid %m");
		exit(1);
	}

	int maxfds = 0;

	FD_SET(ctx.serv_sock, &(ctx.r_master));
	maxfds = max(maxfds, ctx.serv_sock);

	struct timeval to;
	to.tv_sec = S4A_5_MINUTES;
	to.tv_usec = 0;

	time_t now = time(NULL);
	time_t before = now;

	while (ctx.keepalive) {
		int ret = 0;
		int minfds = 0;
		int client_sock = 0;

		time_t diff = now - before;
		if ((diff >= 0) && (diff < to.tv_sec)) {
			to.tv_sec -= diff;
		}
		else {
			to.tv_sec = S4A_5_MINUTES;
			to.tv_usec = 0;

			/* Timeout period exceeded  without select noticing it*/
			Aggregator_aggregate(&ctx);
			Aggregator_pushtoqueue(&ctx);
		}
		before = now;

		if (S4ACtx_ensure_writer(&ctx) == NULL) {
			syslog(LOG_ERR, "Error creating writer %m");
			exit(1);
		}
		if ((!MsgQueue_empty(&(ctx.w_qu))) || (ctx.w_buf != NULL)) {
			FD_SET(ctx.writer->pipe, &(ctx.w_master));
			maxfds = max(maxfds, ctx.writer->pipe);
		}
		else {
			FD_CLR(ctx.writer->pipe, &(ctx.w_master));
		}

		fd_set r_tst = ctx.r_master;
		fd_set w_tst = ctx.w_master;
		ret = select(maxfds + 1, &r_tst, &w_tst, NULL, &to);
		now = time(NULL);

		if ((ret == -1) && (errno == EINTR)) {

			/*
			 * Signal handling
			 * */
			
			if (is_set_reload_conf) {
				syslog(LOG_INFO, "Configuration reload not implemented yet");
				is_set_reload_conf = 0;
			}

			if (is_set_display_status) {
				S4ACtx_log(&ctx);
				is_set_display_status = 0;
			}
			
			if (is_set_shutdown) {
				S4ACtx_shutdown(&ctx);
				is_set_shutdown = 0;
			}
			continue;
		}

		if (ret < 0) {
			syslog(LOG_ERR, "select %m");
			exit(1);
		}

		if (ret == 0) {
			before = now;
			to.tv_sec = S4A_5_MINUTES;
			to.tv_usec = 0;

			/*
			 * Handle aggregations
			 * */

			Aggregator_aggregate(&ctx);
			Aggregator_pushtoqueue(&ctx);

			continue;
		}

		/* From here on we have descriptors to read from and to write to */

		int tmprlen = MsgQueue_length(&(ctx.r_qu));
		if (ctx.rq_maxlen < tmprlen) {
			ctx.rq_maxlen = tmprlen;
		}

		int tmpwlen = MsgQueue_length(&(ctx.w_qu));
		if (ctx.wq_maxlen < tmpwlen) {
			ctx.wq_maxlen = tmpwlen;
		}


		/*
		 * Handle accepts
		 * */	
		if (FD_ISSET(ctx.serv_sock, &r_tst)) {
			struct sockaddr_un remote;
			socklen_t s_len = sizeof(remote);
			bzero((char *) &remote, sizeof (remote));
			if ((client_sock = accept(ctx.serv_sock, (struct sockaddr *)&remote, &s_len)) == -1) {
				syslog(LOG_ERR, "accept %m");
				exit(1);
			}
			syslog(LOG_DEBUG, "New connection accepted (%d)", client_sock);

			FD_SET(client_sock, &(ctx.r_master));
			maxfds = max(maxfds, client_sock);
			minfds = (minfds == 0) ? client_sock : min(minfds, client_sock);
			if (MsgQueue_push(&(ctx.r_qu), MsgQueueEntry_new(client_sock)) == -1) {
				syslog(LOG_NOTICE, "Error adding connection (%d) to queue", client_sock);
			}
		}

		/*
		 * Handle reads
		 * */
		for (client_sock = minfds; client_sock <= maxfds; client_sock++) {
			if (FD_ISSET(client_sock, &r_tst)) {
				MsgQueueEntry *ee = MsgQueue_peek(&(ctx.r_qu), client_sock);
				if (ee == NULL) {
					syslog(LOG_NOTICE, "No buffer found for connection (%d). Probably an error", client_sock);
					S4ACtx_close_client(&ctx, client_sock, ee);
				}
				else {
					ssize_t data_len = recv(client_sock, data, BUF_SIZE, 0);
					if (data_len < 0) {
						syslog(LOG_ERR, "Recieve failed for connection (%d) %m", client_sock);
						S4ACtx_close_client(&ctx, client_sock, ee);
					}
					else if (data_len == 0) {
						if (!MsgBuffer_readready(&(ee->mb))) {
							syslog(LOG_ERR, "Connection was closed by client (%d) too early", client_sock);
							S4ACtx_close_client(&ctx, client_sock, ee);
						}
						else {
							close(client_sock);
							FD_CLR(client_sock, &(ctx.r_master));
						}
					}
					else {
						if (MsgBuffer_read(&(ee->mb), data, data_len, -1) == -1) {
							syslog(LOG_ERR, "Invalid message by client (%d)", client_sock);
							S4ACtx_close_client(&ctx, client_sock, ee);
						}
						else {
							if (MsgBuffer_readready(&(ee->mb))) {
								S4ACtx_handle(&ctx, ee);
								S4ACtx_close_client(&ctx, client_sock, ee);
							}
						}
					}
				}
			}
		}

		/* 
		 * Check writer 
		 * in case of error - new writer and any unfinished things must be stopped
		 * old writer must be cast away from SETs also 
		 */

		S4ACtx_check_writer_status(&ctx);

		/*
		 * Handle writes
		 * */
		if (ctx.writer) {
			if (FD_ISSET(ctx.writer->pipe, &w_tst)) {
				while (1) {
					if (ctx.w_buf == NULL) {
						ctx.w_buf = MsgQueue_pop(&(ctx.w_qu));
					}
					if (ctx.w_buf) {
						if (MsgBuffer_send(&(ctx.w_buf->mb), ctx.writer->pipe) == -1) {
							syslog(LOG_ERR, "Cannot connect to writer process %m");
							kill(ctx.writer->pid, SIGKILL);
							break; // no one to send to
						}
						else {
							if (MsgBuffer_nothingtosend(&(ctx.w_buf->mb))) {
								MsgQueueEntry_free(ctx.w_buf);
								ctx.w_buf = NULL;	
							}
							else {
								break; // would block
							}
						}
					}
					else {
						break;  // w_qu empty
					}
				}
			}
		}

		S4ACtx_check_writer_status(&ctx);
	}
}

void handle_rrd(const char *detector, const char *file, const char *upd)
{
	if (detector && file && upd) {
		syslog(LOG_DEBUG, "%s %s", detector, file);
		char dirname[BUF_SIZE];
		char filename[BUF_SIZE];
		int ret = 0;
		memset(dirname, 0, BUF_SIZE);
		memset(filename, 0, BUF_SIZE);
		ret = snprintf(dirname, BUF_SIZE, "%s/%s", S4A_DETECTORS, detector);
		if (ret >= BUF_SIZE) {
			syslog(LOG_WARNING, "%d bytes for path was not enough to handle %s", BUF_SIZE, detector);
			return;
		}
		if (ret < 0) {
			syslog(LOG_WARNING, "Error occured while preparing rrd: %m");
			return;
		}

		ret = snprintf(filename, BUF_SIZE, "%s/%s/%s.rrd", S4A_DETECTORS, detector, file);
		if (ret >= BUF_SIZE) {
			syslog(LOG_WARNING, "%d bytes for path was not enough to handle %s for %s", BUF_SIZE, file, detector);
			return;
		}
		if (ret < 0) {
			syslog(LOG_WARNING, "Error occured while preparing rrd: %m");
			return;
		}

		if (ensure_directory(dirname, NULL) == -1) {
			syslog(LOG_WARNING, "Unable to create directory %s: %m", dirname);
			return;
		}
	
		if (store_single_rrd(file, filename, upd) != 0) {
			syslog(LOG_WARNING, rrd_get_error());
			rrd_clear_error();
			return;
		}
	}
	else {
		syslog(LOG_WARNING, "Invalid input for RRD handling");
	}
}

int handle_msg(MsgBuffer *mb)
{
	#define S4A_TOKENS_IN_WRITER_MSG 3 

	int ret = -1;
	if (mb) {
		syslog(LOG_DEBUG, "%d %s", (int)(mb->data_b.len), mb->data_b.buf);

		char *data[S4A_TOKENS_IN_WRITER_MSG];
		int ii = 0;
		for (ii = 0; ii < S4A_TOKENS_IN_WRITER_MSG; ii++) {
			data[ii] = NULL;
		}

		char *inp = mb->data_b.buf;
	
		ii = 0;
		for (ii = 0; ii < S4A_TOKENS_IN_WRITER_MSG; ii++) {
			data[ii] = strsep(&inp, "\t");
			if (data[ii] == NULL) {
				syslog(LOG_WARNING, "Invalid message: %d  %s", ii, mb->data_b.buf);
				int jj = 0;
				for (jj = 0; jj < ii; jj++) {
					syslog(LOG_WARNING, "%s", data[jj]);
				}
				goto error;
			}
		}

		handle_rrd(data[0], data[1], data[2]);
	}
	else {
		syslog(LOG_NOTICE, "Anomaly in file (%s), line (%d)", __FILE__, __LINE__);
		goto error;
	}

	ret = 0;

error:

	return ret;
}


void writer_main(int p0, int p1)
{
	unsigned char buf[BUF_SIZE];
	ssize_t ret = 0;

	MsgBuffer cmd;
	MsgBuffer_init(&cmd);

	openlog("s4a-writer", LOG_PID, LOG_LOCAL3);
	
	syslog(LOG_INFO, "Started");

	if (close(p1) == -1) {
		syslog(LOG_ERR, "close %m");
		_exit(1);
	}
		
	if (dup2(p0, 0) == -1) {
		syslog(LOG_ERR, "dup2 %m");
		_exit(1);
	}

	if (closefrom(1) == -1) {
		syslog(LOG_ERR, "closefrom %m");
		_exit(1);
	} 

	while ((ret = read(0, buf, BUF_SIZE))) {
		if (ret == -1) {
			syslog(LOG_ERR, "read %m");
			_exit(1);
		}
		if (ret > 0) {
			ssize_t t_len = ret;
			unsigned char* t_buf = buf;
			while (1) {
				ret = MsgBuffer_read(&cmd, t_buf, t_len, S4A_MAX_PACKAGE);
				if (ret == -1) {
					MsgBuffer_reinit(&cmd);
					syslog(LOG_WARNING, "Invalid message");
					_exit(1);
				}
	
				t_len -= ret;
				t_buf = t_buf + ret;
				if (MsgBuffer_readready(&cmd)) {
					if (handle_msg(&cmd) == -1) {
						syslog(LOG_WARNING, "Error handling command");
						_exit(1);
					}
					MsgBuffer_reset(&cmd);
				}
				else {
					break;
				}
			}
		}
		else {
			syslog(LOG_WARNING, "Invalid value %d from read(2)", (int)ret);
			_exit(1);
		}
	}
	syslog(LOG_INFO, "Shutting down");
	MsgBuffer_reinit(&cmd);
	if (close(0) == -1) {
		syslog(LOG_ERR, "close %m");
	}
	closelog();
	_exit(0);
}

int main(void) 
{
	s4a_main();
	return 0;
}

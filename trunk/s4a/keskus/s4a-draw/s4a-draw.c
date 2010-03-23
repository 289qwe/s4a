
/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <rrd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#include <fcntl.h>
#include <err.h>
#include <errno.h>
#include <time.h>
#include <sys/queue.h>
#include <gd.h>
#include <gdfontl.h>
#include <gdfontt.h>

#define DETECTOR_ROOT "/usr/local/share/s4a/detectors"
#define WEBD_ROOT "/var/www/s4a-view/detectors"
#define WEBS_ROOT "/var/www/s4a-view/sigs"

#define CONTAINER_COUNT 15
#define MAX_TEXT_LEN 100
#define MAX_DS 400

SLIST_HEAD(listhead, detector_struct) detectors;
typedef struct detector_struct {
	char *detector;
	SLIST_ENTRY(detector_struct) entries;
} Detector;

size_t g_max_text_len = MAX_TEXT_LEN;
char g_text[MAX_TEXT_LEN];
size_t max_det_len = 0;

typedef struct sigview_struct {
	gdImagePtr cim[MAX_DS];
	int color_back[MAX_DS];
	int color_box[MAX_DS];
	int color_graph[MAX_DS];
	int detno;
} SigView;

char * g_rrdarg[7];
size_t g_rrd_path_max_len;
size_t g_rrd_time_max_len = 9;
int g_rrdarg_len = 7;

char * g_webd_outf = NULL;
size_t g_webd_outf_max_len;
char * g_webs_outf = NULL;
size_t g_webs_outf_max_len;

typedef struct img_ctx_struct {
	int image_width;
	int image_height;
	int box_width;
	int box_height;
	int elems_in_row;
	gdFontPtr font;
} ImgCtx;

ImgCtx g_sig;
ImgCtx g_global;

void initbuffers()
{
	g_rrd_path_max_len = strlen(DETECTOR_ROOT) + 1 + max_det_len + strlen("XXXXXX.rrd") + 1;
	
	// Arguments for RRD-fetch
	g_rrdarg[0] = strdup("mustbeherebutmeansnothing");
	g_rrdarg[1] = strdup("--start");
	g_rrdarg[2] = strdup("now -XXh");
	g_rrdarg[3] = strdup("--end");
	g_rrdarg[4] = strdup("now");
	g_rrdarg[5] = malloc(g_rrd_path_max_len);
	g_rrdarg[6] = strdup("AVERAGE");

	// Images for detector
	g_webd_outf_max_len = strlen(WEBD_ROOT) + 1 + max_det_len + 1 + strlen("img-XXXXXX-XXXXXXXX.png") + 1;
	g_webd_outf = malloc(g_webd_outf_max_len);
	if (g_webd_outf == NULL) {
		err(2, "malloc");
	}

	// Images for signature
	g_webs_outf_max_len = strlen(WEBS_ROOT) + strlen("/XX/img-XX-XXXXXX.png") + 1;
	g_webs_outf = malloc(g_webs_outf_max_len);
	if (g_webs_outf == NULL) {
		err(2, "malloc");
	}
}


void plot_gd(rrd_value_t *data, int rows, int fields, FILE **of, ImgCtx *img, SigView *sw)
{
	gdImagePtr im[4];
	int color_text[4];
	int color_box[4];
	int color_back[4];
	int color_graph[4];

	int ii;
	for (ii = 0; ii < 4; ii++) {
		im[ii] = gdImageCreate(img->image_width, img->image_height);
	}

	for (ii = 0; ii < 4; ii++) {
		// NB! First allocated color shall be background
		color_back[ii] = gdImageColorAllocate(im[ii], 0, 0, 0);
		color_text[ii] = gdImageColorAllocate(im[ii], 255, 255, 0);
		color_box[ii] = gdImageColorAllocate(im[ii], 0, 64, 0);
		color_graph[ii] = gdImageColorAllocate(im[ii], 0, 191, 0);
	}

	int rc = 0;
	int fc = 0;

	double avg[4];
	avg[0] = 0;
	avg[1] = 0;
	avg[2] = 0;
	avg[3] = 0;

	int is_zero[4];
	is_zero[0] = 0;
	is_zero[1] = 0;
	is_zero[2] = 0;
	is_zero[3] = 0;

	int avg_cnt[4];
	avg_cnt[0] = 0;
	avg_cnt[1] = 0;
	avg_cnt[2] = 0;
	avg_cnt[3] = 0;

	for (rc = 0; rc < rows; rc++) {
		for (fc = 0; fc < fields; fc++) {
			int idx = rc*fields + fc;
			if (!isnan(data[idx])) {
				avg[fc % 4] += data[idx];
				avg_cnt[fc % 4]++;
			}
		}
	}

	for (ii = 0; ii < 4; ii++) {
		if (avg_cnt[ii] > 0) {
			avg[ii] /= avg_cnt[ii];
		}
		if (avg[ii] == 0) {
			avg[ii] = 1;
			is_zero[ii] = 1;
		}
	}

	rc = 0;
	int dx = 0;
	while (rc < rows) {
		for (fc = 0; fc < fields; fc++) {

			int cboxx = 0;
			int cboxy = 0;
			if (sw) {
				cboxx = sw->detno;
				cboxy = 0;
				while (cboxx >= img->elems_in_row) {
					cboxx -= img->elems_in_row;
					cboxy++;
				}
			}
			int ctmp_x_l = cboxx*img->box_width;
			int ctmp_y_l = cboxy*img->box_height;

			int idx = rc * fields + fc;
			rrd_value_t val = data[idx];
			if ((dx < img->box_width) && (!isnan(val))) {
				int dy = ((val / avg[fc % 4]) * (img->box_height / 2));
				if (dy > img->box_height) {
					dy = img->box_height;
				}

				int boxx = (fc / 4);
				int boxy = 0;
				while (boxx >= img->elems_in_row) {
					boxx -= img->elems_in_row;
					boxy++;
				}

				int tmp_x_l = boxx*img->box_width;
				int tmp_y_l = boxy*img->box_height;
				if (dy > 0) {
					gdImageLine(im[fc % 4], 
							tmp_x_l + dx, img->box_height + tmp_y_l, 
							tmp_x_l + dx, img->box_height - dy + tmp_y_l, color_graph[fc % 4]);

					if (sw) {
						gdImageLine(sw->cim[fc], 
								ctmp_x_l + dx, img->box_height + ctmp_y_l, 
								ctmp_x_l + dx, img->box_height - dy + ctmp_y_l, sw->color_graph[fc]);
					}
				}
			}
			if (sw && (dx == 0)) {
				gdImageRectangle(sw->cim[fc],
						ctmp_x_l, ctmp_y_l, 
						ctmp_x_l + img->box_width, ctmp_y_l + img->box_height, sw->color_box[fc]);
			}
		}
		rc++;
		dx++;
	} 

	int jj;
	int kk;
	for (jj = 0; jj < 4; jj++) {
		for (kk = 0; kk < img->elems_in_row; kk++) {
			int tmp_x_l = kk*img->box_width;
			int tmp_y_l = jj*img->box_height;
			int tmp_x_u = tmp_x_l + img->box_width;
			int tmp_y_u = tmp_y_l + img->box_height;
			for (ii = 0; ii < 4; ii++) {
				gdImageRectangle(im[ii], tmp_x_l, tmp_y_l, tmp_x_u, tmp_y_u, color_box[ii]);
				if (is_zero[ii]) {
					snprintf(g_text, g_max_text_len, "%0.2f", 0.0);
				}
				else {
					snprintf(g_text, g_max_text_len, "%0.2f", avg[ii]);
				}
				gdImageString(im[ii], img->font, img->font->w, img->font->h / 2, g_text, color_text[ii]); 
			}
		}
	}

	for (ii = 0; ii < 4; ii++) {
		gdImagePng(im[ii], of[ii]);
		gdImageDestroy(im[ii]);
	}
}

void plot_detector_gd(char *detector, int file, ImgCtx *img, SigView *sw)
{
	time_t end = 0; 
	time_t start = 0;

	unsigned long step = 0;
	unsigned long ds_cnt = 0;
	unsigned long i = 0;

	int rowcount = 0;
	rrd_value_t *data = NULL;
	char **ds_namv = NULL;

	snprintf(g_rrdarg[2], g_rrd_time_max_len, "now -6h");
	snprintf(g_rrdarg[5], g_rrd_path_max_len, "%s/%s/%d.rrd", DETECTOR_ROOT, detector, file);
	if (rrd_fetch(g_rrdarg_len, g_rrdarg, &start, &end, &step, &ds_cnt, &ds_namv, &data) != -1) {
		rowcount =  (end - start) / step;
		FILE* of[4];
		snprintf(g_webd_outf, g_webd_outf_max_len, "%s/%s/img-%d-%s.png", WEBD_ROOT, detector, file, "alerts");
		of[0] = fopen(g_webd_outf, "wb");
		snprintf(g_webd_outf, g_webd_outf_max_len, "%s/%s/img-%d-%s.png", WEBD_ROOT, detector, file, "intip");
		of[1] = fopen(g_webd_outf, "wb");
		snprintf(g_webd_outf, g_webd_outf_max_len, "%s/%s/img-%d-%s.png", WEBD_ROOT, detector, file, "extip");
		of[2] = fopen(g_webd_outf, "wb");
		snprintf(g_webd_outf, g_webd_outf_max_len, "%s/%s/img-%d-%s.png", WEBD_ROOT, detector, file, "srcdst");
		of[3] = fopen(g_webd_outf, "wb");
		plot_gd(data, rowcount, ds_cnt, of, img, sw);
		fclose(of[0]);
		fclose(of[1]);
		fclose(of[2]);
		fclose(of[3]);
		for (i = 0; i < ds_cnt; i++) {
			free(ds_namv[i]);
		}
		free(ds_namv);
		free (data);
	}
}

void plot_global_detector_gd(char *detector, ImgCtx *img)
{
	time_t end = 0; 
	time_t start = 0;

	unsigned long step = 0;
	unsigned long ds_cnt = 0;
	unsigned long i = 0;

	int rowcount = 0;
	rrd_value_t *data = NULL;
	char **ds_namv = NULL;

	snprintf(g_rrdarg[2], g_rrd_time_max_len, "now -24h");
	snprintf(g_rrdarg[5], g_rrd_path_max_len, "%s/%s/global.rrd", DETECTOR_ROOT, detector);
	if (rrd_fetch(g_rrdarg_len, g_rrdarg, &start, &end, &step, &ds_cnt, &ds_namv, &data) != -1) {
		rowcount =  (end - start) / step;
		FILE* of[4];
		snprintf(g_webd_outf, g_webd_outf_max_len, "%s/%s/img-global-%s.png", WEBD_ROOT, detector, "alerts");
		of[0] = fopen(g_webd_outf, "wb");
		snprintf(g_webd_outf, g_webd_outf_max_len, "%s/%s/img-global-%s.png", WEBD_ROOT, detector, "sigs");
		of[1] = fopen(g_webd_outf, "wb");
		snprintf(g_webd_outf, g_webd_outf_max_len, "%s/%s/img-global-%s.png", WEBD_ROOT, detector, "badratio");
		of[2] = fopen(g_webd_outf, "wb");
		snprintf(g_webd_outf, g_webd_outf_max_len, "%s/%s/img-global-%s.png", WEBD_ROOT, detector, "extip");
		of[3] = fopen(g_webd_outf, "wb");
		plot_gd(data, rowcount, ds_cnt, of, img, NULL);
		fclose(of[0]);
		fclose(of[1]);
		fclose(of[2]);
		fclose(of[3]);
		for (i = 0; i < ds_cnt; i++) {
			free(ds_namv[i]);
		}
		free(ds_namv);
		free (data);
	}
}


void layoutdisk()
{
	Detector *det = NULL;
	char *dirn = NULL;

	size_t dirn_len = strlen(WEBD_ROOT) + 1 + max_det_len + 1;

	dirn = malloc(dirn_len);
	if (dirn == NULL) {
		err(2, "malloc");
	}
 
	SLIST_FOREACH(det, &detectors, entries)
		{
			snprintf(dirn, dirn_len, "%s/%s", WEBD_ROOT, det->detector);
			if (mkdir(dirn, S_IRWXU | S_IRGRP | S_IXGRP) < 0) {
				if (errno != EEXIST) {
					err(2, "mkdir");
				}
			} 
		}

	free(dirn);
}


void layoutdisk2()
{
	char *dirn = NULL;

	size_t dirn_len = strlen(WEBS_ROOT) + 1 + 2 + 1;

	dirn = malloc(dirn_len);
	if (dirn == NULL) {
		err(2, "malloc");
	}

	int ii = 0;
	for (ii = 0; ii < CONTAINER_COUNT; ii++) { 
		snprintf(dirn, dirn_len, "%s/%d", WEBS_ROOT, ii);
		if (mkdir(dirn, S_IRWXU | S_IRGRP | S_IXGRP) < 0) {
			if (errno != EEXIST) {
				err(2, "mkdir");
			}
		} 
	}

	free(dirn);
}

void getdetectors()
{
	char *buf, *ebuf, *cp;
	long base;
	size_t bufsize;
	int fd, nbytes;
	struct stat sb;
	struct dirent *dp;

	if ((fd = open(DETECTOR_ROOT, O_RDONLY)) < 0)
		err(2, "cannot open %s", DETECTOR_ROOT);

	if (fstat(fd, &sb) < 0)
		err(2, "fstat");

	bufsize = sb.st_size;
	if (bufsize < sb.st_blksize)
		bufsize = sb.st_blksize;

	if ((buf = malloc(bufsize)) == NULL)
		err(2,  "cannot malloc %lu bytes", (unsigned long)bufsize);

	while ((nbytes = getdirentries(fd, buf, bufsize, &base)) > 0) {
		ebuf = buf + nbytes;
		cp = buf;
		while (cp < ebuf) {
			dp = (struct dirent *)cp;
			if (dp->d_fileno != 0) {
				if ((strcmp(".", dp->d_name) != 0) && (strcmp("..", dp->d_name) != 0)) {
					Detector *det = NULL;
					det = malloc(sizeof(Detector));
					if (det == NULL) {
						err(2, "malloc");
					}
					det->detector = strdup(dp->d_name);
					if (det->detector == NULL) {
						err(2, "strdup");
					}
					
					size_t det_len = strlen(det->detector);
					if (det_len > max_det_len) {
						max_det_len = det_len;
					}

					// Keep detectors sorted
					Detector *prev = NULL;
					Detector *np = NULL;
					SLIST_FOREACH(np, &detectors, entries) 
						{
							if (strcmp(np->detector, det->detector) > 0) {
								if (prev == NULL) {
									SLIST_INSERT_HEAD(&detectors, det, entries);
								}
								else {
									SLIST_INSERT_AFTER(prev, det, entries);
								}
								det = NULL;
								break;
							}
							prev = np;
						}

					if (det) {
						if (prev == NULL) {
							SLIST_INSERT_HEAD(&detectors, det, entries);
						}
						else {
							SLIST_INSERT_AFTER(prev, det, entries);
						}
					}
				}
			}
			cp += dp->d_reclen;
		}
	}

	if (nbytes < 0)
		err(2, "getdirentries");
	free(buf);
}

void handle_container(int cont)
{
	Detector *det = NULL;
	SigView sw;

	int ii;
	for (ii = 0; ii < MAX_DS; ii++) {
		sw.cim[ii] = gdImageCreate(1800, 72);
		sw.color_back[ii] = gdImageColorAllocate(sw.cim[ii], 0, 0, 0);
		sw.color_box[ii] = gdImageColorAllocate(sw.cim[ii], 0, 64, 0);
		sw.color_graph[ii] = gdImageColorAllocate(sw.cim[ii], 0, 191, 0);
	}

	g_sig.image_width = 1800;
	g_sig.image_height = 72;
	g_sig.box_width = 72;
	g_sig.box_height = 18;
	g_sig.elems_in_row = 25;
	g_sig.font = gdFontGetTiny();

	sw.detno = 0;
	SLIST_FOREACH(det, &detectors, entries)
		{
			if (strcmp("s4a-detector", det->detector) == 0) {
				plot_detector_gd(det->detector, cont, &g_sig, NULL);
			}
			else {
				plot_detector_gd(det->detector, cont, &g_sig, &sw);
				sw.detno++;
			}
		}

	for (ii = 0; ii < MAX_DS; ii++) {

		FILE *of = NULL;
		const char *e0 = "alerts";
		const char *e1 = "intip";
		const char *e2 = "extip";
		const char *e3 = "srcdst";

		char *ext = NULL;

		switch (ii % 4) {
			case 0:
				ext = (char *)e0;
				break;
			case 1: 
				ext = (char *)e1;
				break;
			case 2:
				ext = (char *)e2;
				break;
			case 3:
				ext = (char *)e3;
				break;
		}
		
		snprintf(g_webs_outf, g_webs_outf_max_len, "%s/%d/img-%d-%s.png", WEBS_ROOT, cont, ii / 4, ext);
		of = fopen(g_webs_outf, "wb");
		gdImagePng(sw.cim[ii], of);
		fclose(of);
		gdImageDestroy(sw.cim[ii]);
		sw.cim[ii] = NULL;
	}
}

int main (int argc, char ** argv) 
{
	SLIST_INIT(&detectors);
	getdetectors();
	initbuffers();
	layoutdisk();
	layoutdisk2();

	int ii = 0;
	for (ii = 0; ii < CONTAINER_COUNT; ii++) {
		handle_container(ii);
	}

	g_global.image_width = 288;
	g_global.image_height = 72;
	g_global.box_width = 288;
	g_global.box_height = 72;
	g_global.elems_in_row = 1;
	g_global.font = gdFontGetLarge();

	Detector *det = NULL;
	SLIST_FOREACH(det, &detectors, entries)
		{
			if (strcmp(det->detector, "s4a-detector") != 0) {
				plot_global_detector_gd(det->detector, &g_global);
			}
		}

	return 0;
}

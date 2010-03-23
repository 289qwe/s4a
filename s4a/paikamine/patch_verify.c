/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

/*
	verify file using RSA key
*/

#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "openssl/crypto.h"
#include "openssl/evp.h"
#include "openssl/rsa.h"
#include "openssl/bio.h"
#include "openssl/pem.h"
#include "openssl/x509.h"

int usage();
X509* getcert(char* filename);

int main(int argc, char** argv)
{
	int ch;
	char* certfile= 0;
	char* datafile= 0;
	char* signfile= 0;
	EVP_MD_CTX ctx;
	int fd= -1;
	X509* cert= 0;
	EVP_PKEY* pkey= 0;
	unsigned int len;
	unsigned char buf[2048];
	int retval= 1;

	EVP_MD_CTX_init(&ctx);
	
	while((ch= getopt(argc, argv, "c:i:s:h")) != EOF){
		switch(ch){
			case 'c':
				certfile= optarg;
				break;
			case 'i':
				datafile= optarg;
				break;
			case 's':
				signfile= optarg;
				break;
			case 'h':
			default:
				usage();
				break;
		}
	}
	if(certfile == 0){
		fprintf(stderr, "missing certfile name\n");
		usage();
	}
	if(signfile == 0){
		fprintf(stderr, "missing signfile name\n");
		usage();
	}
	if(datafile == 0){
		fprintf(stderr, "missing datafile name\n");
		usage();
	}
	if((cert= getcert(certfile)) == 0){
		goto err;
	}
	if((fd= open(datafile, O_RDONLY)) == -1){
		fprintf(stderr, "unable to open datafile\n");
		exit(1);
	}
	EVP_VerifyInit(&ctx, EVP_sha1());
	while((len= read(fd, buf, sizeof(buf))) > 0){
		EVP_VerifyUpdate(&ctx, buf, len);
	}
	close(fd);
	fd= -1;
	if((fd= open(signfile, O_RDONLY)) == -1){
		fprintf(stderr, "unable to open signfile\n");
		goto err;
	}
	if((len= read(fd, buf, sizeof(buf))) <= 0){
		fprintf(stderr, "unable to read signfile\n");
		goto err;
	}
	pkey= X509_get_pubkey(cert);
	if(EVP_VerifyFinal(&ctx, buf, len, pkey) <= 0){
		fprintf(stderr, "unable to verify file\n");
		goto err;
	}
	retval= 0;

err:
	
	if (EVP_MD_CTX_cleanup(&ctx) == 0) {
		fprintf(stderr, "unable to cleanup EVP_MD_CTX\n");
	}
	EVP_PKEY_free(pkey);
	X509_free(cert);
	if (fd != -1) {
		close(fd);
	}
	exit(retval);
}

int usage()
{
	fprintf(stderr, "usage: verify -c <cert file> -i <input filename> -s <signature file>\n");
	exit(1);
}

X509* getcert(char* filename)
{
	BIO* in;
	X509* retval= 0;

	if((in= BIO_new(BIO_s_file())) == 0){
		fprintf(stderr, "unable to create file bio\n");
		goto err;
	}
	if(BIO_read_filename(in, filename) <= 0){
		fprintf(stderr, "unable to set bio filename\n");
		goto err;
	}
	if((retval= PEM_read_bio_X509(in, 0, 0, 0)) == 0){
		fprintf(stderr, "unable to load key\n");
		goto err;
	}
err:
	if(in != 0){
		BIO_free(in);
	}
	return(retval);
}


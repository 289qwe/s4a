/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

/*
	sign file using RSA key
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

int usage();
RSA* getrsa(char* filename);

int main(int argc, char** argv)
{
	int ch;
	char* keyfile= 0;
	char* datafile= 0;
	char* signfile= 0;
	EVP_MD_CTX ctx;
	int fd= -1;
	RSA* rsa= 0;
	EVP_PKEY static_pkey;
	unsigned int len;
	unsigned char buf[2048];
	int retval= 1;

	OpenSSL_add_all_algorithms();
	EVP_MD_CTX_init(&ctx);
	
	while((ch= getopt(argc, argv, "k:i:s:h")) != EOF){
		switch(ch){
			case 'k':
				keyfile= optarg;
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
	if(keyfile == 0){
		fprintf(stderr, "missing keyfile name\n");
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
	if((rsa= getrsa(keyfile)) == 0){
		goto err;
	}
	static_pkey.type= EVP_PKEY_RSA;
	static_pkey.pkey.rsa= rsa;

	if((fd= open(datafile, O_RDONLY)) == -1){
		fprintf(stderr, "unable to open datafile\n");
		exit(1);
	}
	EVP_SignInit(&ctx, EVP_sha1());
	while((len= read(fd, buf, sizeof(buf))) > 0){
		EVP_SignUpdate(&ctx, buf, len);
	}
	close(fd);
	fd= -1;
	if(EVP_SignFinal(&ctx, buf, &len, &static_pkey) == 0){
		fprintf(stderr, "unable to sign file\n");
		goto err;
	}
	if((fd= open(signfile, O_WRONLY | O_CREAT | O_TRUNC, 0644)) == -1){
		fprintf(stderr, "unable to open signfile\n");
		goto err;
	}
	if(write(fd, buf, len) != len){
		fprintf(stderr, "unable to write signfile\n");
		unlink(signfile);
		goto err;
	}
	retval= 0;

err:
	
	if (EVP_MD_CTX_cleanup(&ctx) == 0) {
		fprintf(stderr, "unable to cleanup EVP_MD_CTX\n");
	}
	RSA_free(rsa);
	if (fd != -1) {
		close(fd);
	}
	exit(retval);
}

int usage()
{
	fprintf(stderr, "usage: sign -k <key file> -i <input filename> -s <signature file>\n");
	exit(1);
}

RSA* getrsa(char* filename)
{
	BIO* in;
	RSA* retval= 0;

	if((in= BIO_new(BIO_s_file())) == 0){
		fprintf(stderr, "unable to create file bio\n");
		goto err;
	}
	if(BIO_read_filename(in, filename) <= 0){
		fprintf(stderr, "unable to set bio filename\n");
		goto err;
	}
	if((retval= PEM_read_bio_RSAPrivateKey(in, 0, 0, 0)) == 0){
		fprintf(stderr, "unable to load key\n");
		goto err;
	}
err:
	if(in != 0){
		BIO_free(in);
	}
	return(retval);
}


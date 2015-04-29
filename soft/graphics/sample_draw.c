

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include "graphics.h"


void SampleDraw(T_IMGBUF* img);


/* ���C���֐� */
int main(int argc, char *argv[])
{
	char			fname[64];
	int				fd;
	unsigned char	*pBase;
	int				iDevNum    = 2;
	unsigned long	ulAreaSize = 1024*4*480;
	T_IMGBUF 		img;
	
	/* �R�}���h���C����� */
	if ( argc >= 2 ) {
		iDevNum = strtol(argv[1], NULL, 0);
	}
	
	/* UIO�I�[�v�� */
	sprintf(fname, "/dev/uio%d", iDevNum);
	fd = open(fname, O_RDWR);
	if (fd == -1) {
		printf("open error: %s\n", fname);
		return 1;
	}
	
	/* �������}�b�v */
	pBase = (unsigned char*)mmap(NULL, ulAreaSize, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if ( pBase == MAP_FAILED) {
		printf("mmap error\n");
		return 1;
	}
	
	/* �o�b�t�@����t�� */
	img.iFormat  = 0;
	img.pData    = pBase;
	img.uiStride = 1024*4;
	img.uiWidth  = 640;
	img.uiHeight = 480;
	
	SampleDraw(&img);
	
	
	/* �N���[�Y */
	munmap(pBase, ulAreaSize);
	close(fd);
	
	return 0;
}



void SampleDraw(T_IMGBUF* img)
{
	T_COLOR		col;
	int			i;
	
	/* �N���A */
	col.uwData = 0;
	Graphics_Clear(img, col);
	
	/* �`�� */
	for ( i = 0; i < 100; i++ ) {
		int	x1, y1, x2, y2;
		
		col.uwData = rand();
		x1 = rand() % img->uiWidth;
		x2 = rand() % img->uiWidth;
		y1 = rand() % img->uiHeight;
		y2 = rand() % img->uiHeight;
		Graphics_Line(img, x1, y1, x2, y2, col);
	}
}



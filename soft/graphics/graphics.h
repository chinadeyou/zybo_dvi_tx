

#ifndef __GRAPHICS_H__
#define __GRAPHICS_H__


// �F�`��
typedef	union t_color {
	unsigned char	ubData;
	unsigned short	uhData;
	unsigned long	uwData;
	struct {
		unsigned char	ubB;
		unsigned char	ubG;
		unsigned char	ubR;
		unsigned char	ubA;
	} bgra;
	struct {
		unsigned char	ubA;
		unsigned char	ubR;
		unsigned char	ubG;
		unsigned char	ubB;
	} argb;
} T_COLOR;


// �摜�o�b�t�@
typedef struct t_imgbuf
{
	int					iFormat;
	unsigned char		*pData;
	unsigned	int		uiStride;	// �o�C�g�T�C�Y
	unsigned	int		uiWidth;	// �s�N�Z����
	unsigned	int		uiHeight;	// �s�N�Z������
} T_IMGBUF;



static inline void Graphics_SetPixel(T_IMGBUF *img, int x, int y, T_COLOR col)
{
	// �͈̓`�F�b�N
	if ( (unsigned int)x >= img->uiWidth || (unsigned int)y >= img->uiHeight ) {
		return;
	}
	
	// �ЂƂ܂��t�H�[�}�b�g��32bit������
	*(unsigned long *)&img->pData[y*img->uiStride + x*4] = col.uwData;
}


void Graphics_Clear(T_IMGBUF *img, T_COLOR col);
void Graphics_Line(T_IMGBUF *img, int x1, int y1, int x2, int y2, T_COLOR col);
void Graphics_Circle(T_IMGBUF *img, int xc, int yc, int r, T_COLOR col);


#endif	/* __GRAPHICS_H__ */



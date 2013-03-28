#include <math.h>

void init_pics(int,int);

char * getCursor(int,int);
void nextPosition(char **);
void printString(char *, int, char **);
void scrollDown(int);
void memcopy(char*, const char*, int);
void printIntDec(long int, char **);
void printIntHex(long int, char **);
int strLength(char *);
//long int pow(int, int);

const int sizeX = 80;
const int sizeY = 25;

unsigned char * color;
//char ale[20] = "Wake up, Neo";  //WORKING

typedef struct
{
	char *val;
	int len;
} string;

void k_main()
{
	init_pics(0x20,0x28);
	*color = 0x07;
	char * cursor = (char *) getCursor(10,10);
	//char alebo[20] = "Wake up, Neo"; //SEGMENTATION FAULT
	string s;
	s.val = "Printing long strings can be fun too because they automatically continue to next line, cool, right?";
	s.len = strLength(s.val);
	cursor = getCursor(0,1);
	printString(s.val, s.len, &cursor);
	cursor = getCursor(0,3);
	s.val = "But we are still in 32-bit mode because size of long int is: ";
	s.len = strLength(s.val);
	printString(s.val, s.len, &cursor);
	printIntDec(sizeof(long int), &cursor);
	nextPosition(&cursor);
	cursor = getCursor(0,4);
	s.val = "Number printing works too: ";
	s.len = strLength(s.val);
	printString(s.val, s.len, &cursor);
	printIntDec(pow(3,5), &cursor);
	printString(" = ", 3, &cursor);
	printIntHex(pow(3,5), &cursor);
	nextPosition(&cursor);
	cursor = getCursor(0,5);
	printString("Cursor pointer: ", 16, &cursor);
	printIntHex((int) cursor, &cursor);
	scrollDown(1);
	while(1) {

	}
}

int strLength(char * str) {
	int c = 0;
	while(str[c] != '\0') ++c;
	return c;
}
void printIntHex(long int n, char ** c) {
	printString("0x", strLength("0x"), c);
	unsigned long int k;	
	int z = 0;
	for (int i = 0; i < ((sizeof(n)*8)/4); ++i)
	{
		k = n;
		k = k << ((4*i));
		k = k >> (sizeof(n)*8-4);
		char znak = k%256+'0';
		if(znak > '9') znak += 'a' - '9' - 1;
		if(znak != '0') z = 1;
		if(z != 0) {
			*c[0] = znak;
			*c[1] = *color;
			nextPosition(c);
		}
	}
	if(z == 0) {
		*c[0] = '0';
		*c[1] = *color;
	}
}

char * getCursor(int x,int y) {
	return (char *) 0xb8000 + sizeX*y*2 + 2*x;
}

void nextPosition(char ** cursor) {
	*cursor = *cursor + 2;
}


//!!!!!Implement new line and other special chars!!!!!!
void printString(char * str, int len, char ** c) {
	for (int i = 0; i < len; ++i)
	{
		*c[0] = str[i];
		*c[1] = *color;
		nextPosition(c);
	}
}

void scrollDown(int n) {
	char * line = (char *) 0xb8000 + n*80*2;
	char * newline = (char *) 0xb8000;

	for (int i = 0; i < sizeY; ++i)
	{
		memcopy(newline, line, sizeX*2);
		line += 160;
		newline += 160;
	}
}

void printIntDec(long int n, char ** c) {
	if(n == 0) {
		*c[0] = '0';
		*c[1] = *color;
		nextPosition(c);
		return;
	}
	long int i = 10;
	long int f = pow(10, 3*((sizeof(n)*8)/10));
	while(n/f == 0) f = f/10;
	while(f>0) {
		int g = n / f;
		n -= g * f;
		f = f/10;
		*c[0] = 0x30 + g;
		*c[1] = *color;
		*c = *c + 2;
	}
}

void memcopy(char *to, const char *from, int count) {
	for (int i = 0; i < count; ++i)
	{
		to[i] = from[i];
	}
}

static inline
void outb( unsigned short port, unsigned char val )
{
    asm volatile( "outb %0, %1"
                  : : "a"(val), "Nd"(port) );
}

static inline
unsigned char inb( unsigned short port )
{
    unsigned char ret;
    asm volatile( "inb %1, %0"
                  : "=a"(ret) : "Nd"(port) );
    return ret;
}

static inline
void io_wait( void )
{
    asm volatile( "jmp 1f\n\t"
                  "1:jmp 2f\n\t"
                  "2:" );
}

#define PIC1 0x20
#define PIC2 0xA0

#define ICW1 0x11
#define ICW4 0x01

/* init_pics()
 * init the PICs and remap them
 */
void init_pics(int pic1, int pic2)
{
	/* send ICW1 */
	outb(PIC1, ICW1);
	outb(PIC2, ICW1);

	/* send ICW2 */
	outb(PIC1 + 1, pic1);	/* remap */
	outb(PIC2 + 1, pic2);	/*  pics */

	/* send ICW3 */
	outb(PIC1 + 1, 4);	/* IRQ2 -> connection to slave */
	outb(PIC2 + 1, 2);

	/* send ICW4 */
	outb(PIC1 + 1, ICW4);
	outb(PIC2 + 1, ICW4);

	/* disable all IRQs */
	outb(PIC1 + 1, 0xFF);
}
void k_main()
{
char *vid = ( char * ) 0xb8000;
int i = 0;
vid[i] = 'H';
i++;
vid[i] = 0x07;

while ( 1 )
{
}
}
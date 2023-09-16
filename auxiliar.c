//-------------------------------------------------------------------
void write_uart(unsigned int);

//-------------------------------------------------------------------
typedef unsigned int fix4_28;

//-----------------------------------------------------------------------
// Devuelve la longitud de una cadena
int strlen(const char *s) {
    int cont=0;
    while (*s != 0) {
        cont++;
        s++;
    }
    return cont;
}


char *reverse(char *cad) {
    int i = strlen(cad);
    i--;
    for (int j = 0; j < i; j++, i--) {
        char aux = cad[j];
        cad[j] = cad[i];
        cad[i] = aux;
    }
    return cad;
}

void _itoa(unsigned int val, char *buf, unsigned int base)
{
    int n_digits = 0;
    unsigned int digit;

    if (base != 2 && base != 10 && base != 16 && base != 8) {
        return;
    }

    do {
        if (base==10) {
            digit = val%10;
            val = val/10;
        } else if (base==2) { 
            digit = val&1;
            val = val >> 1;
        } else if (base==8) {
            digit = val&7;
            val = val >> 3;
        }else {
            digit = val&0xF;
            val = val >> 4;
        }
        if (digit < 10)
            buf[n_digits] = digit + '0';
        else
        {
            buf[n_digits] = digit + 'A' - 10;
        }
        n_digits++;
    } while (val != 0);
    buf[n_digits] = 0;
    reverse(buf);
}



void itoa(unsigned int val, char *buf) {
    return _itoa(val, buf, 10);
}

//-------------------------------------------------------------------
void printString(char *str)
{
	while(*str != '\0')
	write_uart(*str++);
}

//-------------------------------------------------------------------
void printInt(unsigned int val)
{
	char str[11];
	// itoa(val, str);
    _itoa(val,str,10);
	printString(str);
}

void printHex(unsigned int val)
{
	char str[11];
	// itoa(val, str);
    _itoa(val,str,16);
	printString(str);
}

void printBin(unsigned int val)
{
	char str[33];
	// itoa(val, str);
    _itoa(val,str,2);
	printString(str);
}

//----------------------------------------------------------------------
int atoi(char *p) {
    int k = 0;
    while ( (*p - '0' >= 0) && (*p -'0' <= 9)) {
        k = (k << 3) + (k << 1) + (*p) - '0';
        p++;
     }
     return k;
}

//-----------------------------------------------------------------------
// Function to implement a variant of strncpy() function
char* strncpy(char* destination, const char* source, int num)
{
	// return if no memory is allocated to the destination
	if (destination == 0)
		return 0;

	// take a pointer pointing to the beginning of destination string
	char* ptr = destination;

	// copy first num characters of C-string pointed by source
	// into the array pointed by destination
	while (*source && num--)
	{
		*destination = *source;
		destination++;
		source++;
	}

	// null terminate destination string
	*destination = '\0';

	// destination is returned by standard strncpy()
	return ptr;
}

//-----------------------------------------------------------------------
// Function to implement a variant of strncat() function
// num is the max length
char* strncat(char* destination, const char* addendum, int num) {
    int len_0 = strlen(destination);
    int len_1 = strlen(addendum);
    
    int char_to_copy = len_1;
    if (len_1 + len_0 > num) {
        char_to_copy = num - len_0;
    }
    
    return strncpy(destination + len_0,addendum, char_to_copy);
}

//-----------------------------------------------------------------------
// Compara dos cadenas
int strcmp(const char *c1, const char *c2) {
    char ret = *c1-*c2;
    while (ret == 0 && *c1 != 0) {
        c1 ++; c2++;
        ret = *c1 - *c2;
    }
    return ret;
}

//-----------------------------------------------------------------------
// Busca un caracter en una cadena. Devuelve la posicion de la primera ocurrencia
int find(const char c, char *s) {
    int cont = 0;
    while (*(s+cont)!= 0 && c != *(s+cont)) {
        cont++;
    }
    
    if (c != *(s+cont))
        return -1;
    
    return cont;
}


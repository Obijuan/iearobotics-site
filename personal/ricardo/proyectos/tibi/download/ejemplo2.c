#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int main(void) {
	int f;
	char dato;
	
	if ((f = open("/dev/tibi", O_RDWR)) < 0) {
		perror("open");
		exit(-1);
	}
	
	read(f, &dato, 1);
	printf("Dato leido: %d\n", dato);
	
	dato = 0xff;
	write(f, &dato, 1);
	
	return 0;
}
	  
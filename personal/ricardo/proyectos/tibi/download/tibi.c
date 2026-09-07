/*
 * TIBI (Tarjeta de Interface para Bus ISA)
 * v0.1alphaquetecagas
 * Angel Lopez <angel@futur3.com>
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/wrapper.h>
#include <linux/fs.h>
#include <linux/ioport.h>
#include <linux/errno.h>
#include <linux/proc_fs.h>
#include <asm/io.h>
#include <asm/uaccess.h>

static char abierto = 0;
static int major;
static int io;
static unsigned char dato;

/*
 * Funcion de apertura del dispositivo. Unicamente se permite tener
 * abierto el dispositivo a un proceso, si otro proceso lo intenrara
 * abrir recibiria un error EBUSY (dispositivo ocupado).
 * No es necesario realizar ningun tipo de inicializacion del hardware
 * al abrir el dispositivo.
 */
 
static int tibi_open(struct inode *inode, struct file *file) {
	if (abierto)
		return -EBUSY;	
	abierto++;
	MOD_INC_USE_COUNT;
	return 0;
}


/*
 * Funcion de liberacion del dispositivo.
 * Se decrementa el contador de uso, para que otro proceso pueda abrir
 * el dispositivo.
 */
 
static int tibi_release(struct inode *inode, struct file *file) {
	abierto--;
	MOD_DEC_USE_COUNT;
	return 0;
}


/*
 * Funcion de lectura del dispositivo.
 * Se lee el estado de las 8 señales de E/S (un byte de datos) y se 
 * copia este byte a espacio de usuario.
 */
 
static ssize_t tibi_read(struct file *file, char *buffer, size_t lenght, loff_t *offset) {
	put_user(inb(io), buffer);
	return 1;
}


/*
 * Funcion de escritura del dispositivo.
 * Se copia un byte desde espacio de usuario al dispositivo. Este byte aparece
 * en las 8 señales de E/S del conector del dispositivo.
 */ 
 
static ssize_t tibi_write(struct file *file, const char *buffer, size_t length, loff_t *offset) {
	get_user(dato, buffer);
	outb(dato, io);
	return 1;
}


/*
 * Tabla de punteros a las funciones que implementan las llamadas basicas sobre
 * el dispositivo (abrir, cerrar, leer, escribir, etc.)
 */
  
struct file_operations tibi_fops = {
	NULL,		/* seek */
	tibi_read,	/* read	*/
	tibi_write,	/* write */
	NULL,		/* readdir */
	NULL,		/* select */
	NULL,		/* ioctl */
	NULL,		/* mmap */	
	tibi_open,	/* open */
	NULL,		/* flush */
	tibi_release	/* close */
};


/*
 * El modulo recibe un parametro de tipo entero que representa la direccion
 * base de E/S de la tarjeta.
 */
 
MODULE_PARM(io,"1i"); 


/*
 * Funcion que da informacion al usuario sobre el dispositivo y el driver
 * cuando se hace una lectura de la entrada del driver en /proc
 */

int tibi_read_proc(char *buf, char **start, off_t offset, int len, int unused) {
	#define LIMIT (PAGE_SIZE-80)	
	len = 0;
	len += sprintf(buf+len, "Dir. Base E/S: 0x%0x\n", io);
	return len;
}

 
/*
 * Estructura con la informacion necesaria para crear una entrada en /proc
 * que ofrezca informacion sobre el driver y el dispositivo.
 */
 
struct proc_dir_entry tibi_proc_entry = {
	0,			/* inodo */
	4, "tibi",		/* longitud del nombre y nombre */
	S_IFREG | S_IRUGO,	/* fichero regular con lectura para todos */
	1, 0, 0,		/* 1 enlace, propietario y grupo root */
	0,			/* tamaño */
	NULL,			/* operaciones */
	&tibi_read_proc,	/* funcion que lee la informacion */
};
 
/*
 * Inicializacion del modulo. Llamada cuando se carga. Debe registrar el
 * dispositivo.
 * No se indica un major especifico, sino que se deja que se asigne
 * dinamicamente al registrar el dispositivo. Esto implica que habra que
 * crearlo una vez que se sepa el major.
 * Hay que solicitar la direccion base de E/S y asociarla al driver.
 */
 	
int init_module() {
	int err;
	
	if ((major = module_register_chrdev(0, "tibi", &tibi_fops)) < 0) {
		printk("La cagamos amiguete, no puedo pillar el major %d\n", major);
		return major;
	}
	
	printk("Registrado el major %d\n", major);
	printk("Ahora hay que hacer: mknod tibi c %d 0\n", major);
	
	if ((err = check_region(io, 1)) < 0) {
		printk("Oooooops, problemas con la direccion base de E/S 0x%0x\n", io);
		return err;
	}	
	request_region(io, 1, "tibi");

	/* proc_register_dynamic(&proc_root, &tibi_proc_entry); */
		
	return 0;
}


/*
 * Cuando el modulo se descargue, se llamara a esta funcion.
 * Deshace el registro del dispositivo.
 * Libera la direccion de E/S registrada al cargar el modulo.
 */
 
void cleanup_module() {
	if (module_unregister_chrdev(major, "tibi") < 0) {
		printk("¡Oh Dios! No puedo quitar el driver del major %d\n", major);		
	
	}
	
	release_region(io, 1);
}
	 		
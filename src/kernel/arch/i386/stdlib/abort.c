#include <stdio.h>
#include <stdlib.h>

static void
dump_regs_and_stack()
{
	int i;
	register int eax asm("eax");
	register int ebx asm("ebx");
	register int ecx asm("ecx");
	register int edx asm("edx");
	register int esp asm("esp");
	register int ebp asm("ebp");
	register int esi asm("esi");
	register int edi asm("edi");

	printf("Registers:\n");
	printf("  | EAX: 0x%x | EBX: 0x%x | ECX: 0x%x | EDX: 0x%x |\n",
	    eax, ebx, ecx, edx);
	printf("  | ESI: 0x%x | EDI: 0x%x | ESP: 0x%x | EDI: 0x%x|\n",
	    esi, edi, esp, ebp);

	printf("Stack trace:\n");
	for (i = esp-16; i < esp; i++) {
		printf("[0x%x] 0x%x\n", i, (int)(((int *)i)[0]));
	}
}




/**
 * This function is not ment to be directly called.
 * Nothing prevents you from doing so though.
 */
__attribute__((__noreturn__))
void
__panic(char *msg, char *file, int line)
{
	printf("*** kernel panic: %s\n", msg);
	printf("    at line: %d\n", line);
	printf("    in file: %s\n", file); 
	printf("stack trace:\n");
	dump_regs_and_stack();
	while (1) { }
	__builtin_unreachable();
} 


__attribute__((__noreturn__))
void 
abort(void) 
{
	printf("abort()\n");
	while (1) { }
	__builtin_unreachable();
}

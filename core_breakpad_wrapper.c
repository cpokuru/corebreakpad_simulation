#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <sys/types.h>
#include "breakpad_wrapper.h"

void print_banner() {
    printf("╔════════════════════════════════════════╗\n");
    printf("║   RDK Minidump Generator v1.0          ║\n");
    printf("║   Using Breakpad Wrapper               ║\n");
    printf("╚════════════════════════════════════════╝\n\n");
}

void crash_null_pointer() {
    printf("[*] Triggering NULL pointer dereference...\n");
    sleep(1);
    int *ptr = NULL;
    *ptr = 42;  // This will cause SIGSEGV
}

void crash_segfault() {
    printf("[*] Triggering segmentation fault...\n");
    sleep(1);
    char *ptr = (char *)0xDEADBEEF;
    *ptr = 'X';  // Invalid memory access
}

void crash_abort() {
    printf("[*] Triggering abort signal...\n");
    sleep(1);
    abort();  // Sends SIGABRT
}

void crash_stack_overflow() {
    printf("[*] Triggering stack overflow...\n");
    sleep(1);
    crash_stack_overflow();  // Infinite recursion
}

void crash_divide_by_zero() {
    printf("[*] Triggering divide by zero (FPE)...\n");
    sleep(1);
    int x = 42;
    int y = 0;
    volatile int z = x / y;  // SIGFPE
    printf("Result: %d\n", z);
}

void crash_illegal_instruction() {
    printf("[*] Triggering illegal instruction...\n");
    sleep(1);
    raise(SIGILL);  // Simulate illegal instruction
}

void do_some_work() {
    int data[100];
    for (int i = 0; i < 100; i++) {
        data[i] = i * 2;
    }
    printf("[*] Doing some work before crash...\n");
    printf("[*] Array sum: %d\n", data[50]);
}

void print_menu() {
    printf("\nSelect crash type:\n");
    printf("  1. NULL pointer dereference (SIGSEGV)\n");
    printf("  2. Invalid memory access (SIGSEGV)\n");
    printf("  3. Abort signal (SIGABRT)\n");
    printf("  4. Stack overflow (SIGSEGV)\n");
    printf("  5. Divide by zero (SIGFPE)\n");
    printf("  6. Illegal instruction (SIGILL)\n");
    printf("  0. Exit\n\n");
    printf("Choice: ");
}

int main(int argc, char *argv[]) {
    int choice = 1;  // Default: NULL pointer
    
    print_banner();
    
    // Initialize Breakpad using RDK wrapper
    // This function sets up the exception handler to write minidumps to /minidumps/
    printf("[*] Initializing RDK Breakpad Exception Handler...\n");
    printf("[*] Minidumps will be written to: /minidumps/\n");
    
    breakpad_ExceptionHandler();
    
    printf("[✓] Breakpad initialized successfully\n");
    printf("[*] Crash dumps will be automatically uploaded by coredump-upload.service\n\n");
    
    // Parse command line argument if provided
    if (argc > 1) {
        choice = atoi(argv[1]);
        printf("[*] Using crash type: %d\n\n", choice);
    } else {
        print_menu();
        if (scanf("%d", &choice) != 1) {
            printf("[!] Invalid input\n");
            return 1;
        }
    }
    
    printf("\n╔════════════════════════════════════════╗\n");
    printf("║  CRASH INFORMATION                     ║\n");
    printf("╚════════════════════════════════════════╝\n");
    printf("[*] Process ID: %d\n", getpid());
    printf("[*] Process name: %s\n", argv[0]);
    printf("[*] Parent PID: %d\n", getppid());
    printf("[*] Preparing to crash in 2 seconds...\n");
    sleep(2);
    
    // Do some work to make the dump more interesting
    do_some_work();
    
    printf("\n[!] INITIATING CRASH\n");
    printf("────────────────────────────────────────\n\n");
    
    switch (choice) {
        case 1:
            crash_null_pointer();
            break;
        case 2:
            crash_segfault();
            break;
        case 3:
            crash_abort();
            break;
        case 4:
            crash_stack_overflow();
            break;
        case 5:
            crash_divide_by_zero();
            break;
        case 6:
            crash_illegal_instruction();
            break;
        case 0:
            printf("[*] Exiting normally (no crash)\n");
            return 0;
        default:
            printf("[!] Invalid choice, defaulting to NULL pointer\n");
            crash_null_pointer();
    }
    
    printf("[!] This line should never be reached\n");
    return 0;
}

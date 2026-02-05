#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>

// Signal flags
volatile sig_atomic_t sigterm_flag = 0;
volatile sig_atomic_t sigint_flag = 0;

// Signal handlers
void handle_sigterm(int sig) {
    printf("\nParent: Received SIGTERM (signal %d)\n", sig);
    printf("Parent: This signal was sent by Child 1 after 5 seconds\n");
    sigterm_flag = 1;
}

void handle_sigint(int sig) {
    printf("\nParent: Received SIGINT (signal %d)\n", sig);
    printf("Parent: This signal was sent by Child 2 after 10 seconds\n");
    sigint_flag = 1;
}

int main() {
    printf("Signal Handling Demo - Parent PID: %d\n", getpid());
    
    // Set up signal handlers
    signal(SIGTERM, handle_sigterm);
    signal(SIGINT, handle_sigint);
    
    // Create Child 1 (sends SIGTERM after 5 seconds)
    pid_t child1 = fork();
    if (child1 == 0) {
        // Child 1 code
        sleep(5);
        printf("Child 1 (PID: %d): Sending SIGTERM to parent (%d)\n", 
               getpid(), getppid());
        kill(getppid(), SIGTERM);
        exit(0);
    }
    
    // Create Child 2 (sends SIGINT after 10 seconds)
    pid_t child2 = fork();
    if (child2 == 0) {
        // Child 2 code
        sleep(10);
        printf("Child 2 (PID: %d): Sending SIGINT to parent (%d)\n", 
               getpid(), getppid());
        kill(getppid(), SIGINT);
        exit(0);
    }
    
    printf("Parent: Created Child 1 (PID: %d)\n", child1);
    printf("Parent: Created Child 2 (PID: %d)\n", child2);
    printf("\nParent: Running indefinitely...\n");
    printf("Parent: Waiting for signals from children...\n");
    
    // Parent runs until both signals received
    while (1) {
        printf("Parent: Still running...\n");
        
        if (sigterm_flag && sigint_flag) {
            printf("\nParent: Both signals received. Exiting gracefully.\n");
            break;
        }
        
        sleep(1);
    }
    
    // Wait for children to finish
    wait(NULL);
    wait(NULL);
    
    printf("Parent: All children cleaned up. Exiting.\n");
    return 0;
}

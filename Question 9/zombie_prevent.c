#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>
#include <string.h>

#define NUM_CHILDREN 5
#define CHILD_SLEEP_TIME 2

/**
 * Function to demonstrate zombie process using wait()
 */
void demonstrate_wait() {
    printf("\n=== Demonstrating wait() ===\n");
    
    pid_t pid;
    int i;
    
    for (i = 0; i < NUM_CHILDREN; i++) {
        pid = fork();
        
        if (pid < 0) {
            // Fork failed
            perror("fork failed");
            exit(EXIT_FAILURE);
        }
        else if (pid == 0) {
            // Child process
            printf("Child %d (PID: %d) started. Parent PID: %d\n", 
                   i+1, getpid(), getppid());
            
            // Child does some work
            sleep(CHILD_SLEEP_TIME);
            
            printf("Child %d (PID: %d) exiting...\n", i+1, getpid());
            exit(i + 1); // Exit with status
        }
        else {
            // Parent process
            printf("Parent created child %d with PID: %d\n", i+1, pid);
        }
    }
    
    // Parent waits for all children
    printf("\nParent (PID: %d) waiting for children to terminate...\n", getpid());
    
    int status;
    pid_t child_pid;
    
    while ((child_pid = wait(&status)) > 0) {
        if (WIFEXITED(status)) {
            printf("Parent: Child PID %d cleaned up. Exit status: %d\n", 
                   child_pid, WEXITSTATUS(status));
        }
        else if (WIFSIGNALED(status)) {
            printf("Parent: Child PID %d terminated by signal: %d\n", 
                   child_pid, WTERMSIG(status));
        }
    }
    
    printf("Parent: All children cleaned up successfully.\n");
}

/**
 * Function to demonstrate zombie process prevention using waitpid() with WNOHANG
 */
void demonstrate_waitpid_noblock() {
    printf("\n=== Demonstrating waitpid() with WNOHANG (Non-blocking) ===\n");
    
    pid_t pids[NUM_CHILDREN];
    int i;
    
    // Create multiple children
    for (i = 0; i < NUM_CHILDREN; i++) {
        pids[i] = fork();
        
        if (pids[i] < 0) {
            perror("fork failed");
            exit(EXIT_FAILURE);
        }
        else if (pids[i] == 0) {
            // Child process
            printf("Child %d (PID: %d) started. Will sleep for %d seconds\n", 
                   i+1, getpid(), (i+1) * 2);
            
            // Each child sleeps for different time
            sleep((i + 1) * 2);
            
            printf("Child %d (PID: %d) exiting with status %d\n", 
                   i+1, getpid(), (i+1) * 10);
            exit((i + 1) * 10);
        }
        else {
            printf("Parent created child %d with PID: %d\n", i+1, pids[i]);
        }
    }
    
    // Parent continues immediately (non-blocking)
    printf("\nParent (PID: %d) continues working while checking for terminated children...\n", getpid());
    
    int completed = 0;
    int status;
    
    while (completed < NUM_CHILDREN) {
        printf("Parent doing some work...\n");
        sleep(1); // Simulate parent work
        
        // Check for terminated children without blocking
        pid_t child_pid = waitpid(-1, &status, WNOHANG);
        
        if (child_pid > 0) {
            // Found a terminated child
            completed++;
            
            if (WIFEXITED(status)) {
                printf("Parent: Cleaned up child PID %d. Exit status: %d\n", 
                       child_pid, WEXITSTATUS(status));
            }
            
            // Find which child this was
            for (i = 0; i < NUM_CHILDREN; i++) {
                if (pids[i] == child_pid) {
                    pids[i] = 0; // Mark as cleaned up
                    break;
                }
            }
        }
        else if (child_pid == 0) {
            // No children terminated yet
            printf("Parent: No children terminated yet. Continuing...\n");
        }
        else if (child_pid == -1) {
            // Error
            if (errno == ECHILD) {
                printf("Parent: No more children to wait for.\n");
                break;
            }
            else {
                perror("waitpid failed");
                break;
            }
        }
    }
    
    printf("Parent: All %d children cleaned up.\n", completed);
}

/**
 * Function demonstrating SIGCHLD signal handler for zombie prevention
 */
void demonstrate_sigchld_handler() {
    printf("\n=== Demonstrating SIGCHLD Handler ===\n");
    
    // Install SIGCHLD handler
    signal(SIGCHLD, SIG_IGN); // Simple: ignore SIGCHLD, kernel reaps zombies
    
    pid_t pid;
    int i;
    
    for (i = 0; i < NUM_CHILDREN; i++) {
        pid = fork();
        
        if (pid < 0) {
            perror("fork failed");
            exit(EXIT_FAILURE);
        }
        else if (pid == 0) {
            // Child process
            printf("Child %d (PID: %d) created. Will exit immediately.\n", 
                   i+1, getpid());
            exit(0);
        }
        else {
            printf("Parent created child with PID: %d\n", pid);
        }
    }
    
    // Parent sleeps to show children become zombies briefly then are reaped
    printf("\nParent sleeping for 3 seconds...\n");
    sleep(3);
    
    printf("Parent: Children automatically reaped by kernel (SIGCHLD ignored).\n");
    
    // Restore default SIGCHLD behavior
    signal(SIGCHLD, SIG_DFL);
}

/**
 * Function demonstrating waitpid() for specific child
 */
void demonstrate_waitpid_specific() {
    printf("\n=== Demonstrating waitpid() for Specific Child ===\n");
    
    pid_t pids[NUM_CHILDREN];
    int i;
    
    // Create children
    for (i = 0; i < NUM_CHILDREN; i++) {
        pids[i] = fork();
        
        if (pids[i] < 0) {
            perror("fork failed");
            exit(EXIT_FAILURE);
        }
        else if (pids[i] == 0) {
            // Child process
            int sleep_time = (i % 3) + 1; // Different sleep times
            printf("Child %d (PID: %d) will sleep for %d seconds\n", 
                   i+1, getpid(), sleep_time);
            sleep(sleep_time);
            printf("Child %d (PID: %d) exiting\n", i+1, getpid());
            exit(i + 100); // Different exit codes
        }
        else {
            printf("Parent created child %d with PID: %d\n", i+1, pids[i]);
        }
    }
    
    // Parent waits for specific children
    printf("\nParent (PID: %d) waiting for children in specific order...\n", getpid());
    
    // Wait for child 3 specifically
    int status;
    printf("\nWaiting specifically for child 3 (PID: %d)...\n", pids[2]);
    pid_t result = waitpid(pids[2], &status, 0);
    
    if (result > 0 && WIFEXITED(status)) {
        printf("Child 3 (PID: %d) cleaned up. Exit status: %d\n", 
               result, WEXITSTATUS(status));
    }
    
    // Wait for remaining children
    printf("\nWaiting for remaining children...\n");
    
    while ((result = wait(&status)) > 0) {
        if (WIFEXITED(status)) {
            // Find which child this was
            for (i = 0; i < NUM_CHILDREN; i++) {
                if (pids[i] == result) {
                    printf("Child %d (PID: %d) cleaned up. Exit status: %d\n", 
                           i+1, result, WEXITSTATUS(status));
                    break;
                }
            }
        }
    }
    
    printf("All children cleaned up.\n");
}

/**
 * Main function
 */
int main() {
    printf("========================================\n");
    printf("Zombie Process Prevention Demonstration\n");
    printf("========================================\n");
    printf("Parent PID: %d\n", getpid());
    
    // Method 1: Using wait()
    demonstrate_wait();
    
    // Method 2: Using waitpid() with WNOHANG
    demonstrate_waitpid_noblock();
    
    // Method 3: Using SIGCHLD handler
    demonstrate_sigchld_handler();
    
    // Method 4: Using waitpid() for specific child
    demonstrate_waitpid_specific();
    
    printf("\n========================================\n");
    printf("All demonstrations completed successfully!\n");
    printf("========================================\n");
    
    return 0;
}

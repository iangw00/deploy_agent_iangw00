#!/usr/bin/env bash


# --- STEP 1: DEFINE WHAT TO DO IF THE USER PRESSES CTRL+C (SIGINT) ---
emergency_cleanup(){
    echo ""
    echo "Ctrl+C detected! Saving progress and cleaning up..."

    if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
        ARCHIVE_NAME="${PROJECT_DIR}_archive.tar.gz"
        echo "Creating backup archive file: $ARCHIVE_NAME"
        tar -czf "$ARCHIVE_NAME" "$PROJECT_DIR"
        
        echo "Deleting incomplete directory..."
        rm -rf "$PROJECT_DIR"
        
        echo "Project archived successfully. Workspace cleaned."
    else
        echo "No directories were created yet. Exiting safely."
    fi
    exit 1
}
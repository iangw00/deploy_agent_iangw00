#!/usr/bin/env bash


# --- STEP 1: DEFINE WHAT TO DO IF THE USER PRESSES CTRL+C (SIGINT) ---
emergency_cleanup(){
    echo ""
    echo "Ctrl+C detected! Saving progress and cleaning up..."

    if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
        ARCHIVE_NAME="${PROJECT_DIR}_archive"
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
echo "=== Welcome to the Automated Bootstrapping System ==="
echo -n "Enter project name: "
read -r SUFFIX

PROJECT_DIR="attendance_tracker_${SUFFIX}"


if [ -d "$PROJECT_DIR" ]; then
    echo "Error: $PROJECT_DIR already exists!"
    exit 1
fi


trap emergency_cleanup SIGINT


echo "Creating project directories..."
mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"
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


echo "Generating your Python application and data files..."

# 1. Embedded python script (attendance_checker.py)
cat << 'EOF' > "$PROJECT_DIR/attendance_checker.py"
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF


cat << 'EOF' > "$PROJECT_DIR/Helpers/assets.csv"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF


cat << 'EOF' > "$PROJECT_DIR/Helpers/config.json"
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF


cat << 'EOF' > "$PROJECT_DIR/reports/reports.log"
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF

echo "All core files generated successfully."


echo ""
echo "=== Configuration Settings ==="
echo -n "Do you want to update attendance thresholds? (y/n): "
read -r UPDATE_CHOICE

case "$UPDATE_CHOICE" in
    [Yy]*) 
        echo "-> Initiating configuration update..."
        
        
        while true; do
            echo -n "Enter Warning Threshold (e.g., 80 or 80%): "
            read -r RAW_WARN
            
            
            WARN_VAL="${RAW_WARN//%/}"
            
            
            if [[ "$WARN_VAL" =~ ^[0-9]+$ ]]; then
                break
            else
                echo "Invalid input. Please enter numbers only."
            fi
        done

        
        while true; do
            echo -n "Enter Failure Threshold (e.g., 60 or 60%): "
            read -r RAW_FAIL
            
            
            FAIL_VAL="${RAW_FAIL//%/}"
            
            if [[ "$FAIL_VAL" =~ ^[0-9]+$ ]]; then
                break
            else
                echo "Invalid input. Please enter numbers only."
            fi
        done

        echo "Applying configuration patches..."
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS / MacBook Pro specific format (requires the empty '' quotes)
            sed -i '' "s/\"warning\": [0-9]*/\"warning\": $WARN_VAL/" "$PROJECT_DIR/Helpers/config.json"
            sed -i '' "s/\"failure\": [0-9]*/\"failure\": $FAIL_VAL/" "$PROJECT_DIR/Helpers/config.json"
        else
            # Standard Linux / Ubuntu format
            sed -i "s/\"warning\": [0-9]*/\"warning\": $WARN_VAL/" "$PROJECT_DIR/Helpers/config.json"
            sed -i "s/\"failure\": [0-9]*/\"failure\": $FAIL_VAL/" "$PROJECT_DIR/Helpers/config.json"
        fi

        echo "config.json threshold elements dynamically updated."
        ;;

    [Nn]*)
        echo "Keeping original default parameters."
        ;;

    *)
        echo "Invalid response detected. Skipping configuration update and using defaults."
        ;;
esac


echo ""
echo "=== Checking System Health ==="

if python3 --version  &>/dev/null; then
    echo "Python3 detected."
    python3 --version
else
    echo "Warning: Python3 is not installed on this system."
fi



echo ""
echo "🔍 Verification: Confirming all critical project files exist..."

if [ -f "$PROJECT_DIR/attendance_checker.py" ] && \
   [ -f "$PROJECT_DIR/Helpers/assets.csv" ] && \
   [ -f "$PROJECT_DIR/Helpers/config.json" ] && \
   [ -f "$PROJECT_DIR/reports/reports.log" ]; then
    
    echo "Directory structure validated."
else
    echo "Structure validation failed. Some files are missing!"
    exit 1
fi



echo ""
echo "===================================================="
echo "Setup Finished! Project created: $PROJECT_DIR"
echo "===================================================="


trap - SIGINT
exit 0

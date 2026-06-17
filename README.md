# deploy_agent_iangw00

```text
The source logic for a Student Attendance Tracker. Your task is to build a "Project Factory"; a shell script that automates the creation of the workspace, configures settings via the command line, and handles system signals gracefully
```

# Attendance Tracker Bootstrapper

## How to Run the Script

```text
Follow these steps to execute the bootstrapping script on Linux or macOS:
```

1. Make the Script Executable

```text
Before running the script, you need to grant it execution permissions. Open your terminal and run:
```

```bash
chmod +x setup_project.sh
```

2. Execute the Script

```text
Run the script from your terminal:
```

```bash
./setup_project.sh
```

3. Follow the Prompts

- **Project Name**: The script will ask you for a project suffix. If you type v1, it will create a workspace directory named attendance_tracker_{input}. where input is determined by the user.

- **Configuration Update**: You will be prompted to choose whether to customize the attendance thresholds `(y/n)`. If you select yes, enter numeric values for the warning and failure limits.

## How to Trigger the Archive Feature

```text
The script includes an emergency backup and cleanup feature controlled via a POSIX signal trap `(SIGINT)`. If you need to abort the setup mid-process, you can trigger this archive mechanism to safely pack up your progress and clean your workspace.
```

### Steps to Trigger the Archive:

1. Run the script as normal `(./setup_project.sh)`.
2. Press `Ctrl + C` on your keyboard while the script is waiting for user input.


[Video](https://youtube.com)




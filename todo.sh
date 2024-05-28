#!/bin/bash

TODO_FILE="todo_tasks.json"

# Ensure the TODO_FILE exists
if [ ! -f "$TODO_FILE" ]; then
    echo "[]" > "$TODO_FILE"
fi

# Function to load tasks
load_tasks() {
    jq . "$TODO_FILE"
}

# Function to save tasks
save_tasks() {
    echo "$1" > "$TODO_FILE"
}

# Function to create a task
create_task() {
    tasks=$(load_tasks)
    id=$(echo "$tasks" | jq '.[].id' | sort -nr | head -n1)
    id=$((id + 1))
    task=$(jq -n --arg id "$id" --arg title "$1" --arg due_date "$2" --arg description "${3:-}" --arg location "${4:-}" --argjson completion false \
        '{id: $id|tonumber, title: $title, due_date: $due_date, description: $description, location: $location, completion: $completion}')
    tasks=$(echo "$tasks" | jq --argjson task "$task" '. += [$task]')
    save_tasks "$tasks"
    echo "Task $id created."
}

# Function to update a task
update_task() {
    tasks=$(load_tasks)
    task=$(echo "$tasks" | jq --arg id "$1" '.[] | select(.id == ($id|tonumber))')
    if [ -z "$task" ]; then
        echo "No task with ID $1" >&2
        exit 1
    fi
    updated_task=$(echo "$task" | jq --arg title "${2:-}" --arg due_date "${3:-}" --arg description "${4:-}" --arg location "${5:-}" --argjson completion "${6:-false}" \
        'if $title != "" then .title = $title else . end |
         if $due_date != "" then .due_date = $due_date else . end |
         if $description != "" then .description = $description else . end |
         if $location != "" then .location = $location else . end |
         .completion = $completion')
    tasks=$(echo "$tasks" | jq --argjson updated_task "$updated_task" --arg id "$1" 'map(if .id == ($id|tonumber) then $updated_task else . end)')
    save_tasks "$tasks"
    echo "Task $1 updated."
}

# Function to delete a task
delete_task() {
    tasks=$(load_tasks)
    tasks=$(echo "$tasks" | jq --arg id "$1" 'del(.[] | select(.id == ($id|tonumber)))')
    save_tasks "$tasks"
    echo "Task $1 deleted."
}

# Function to show a task
show_task() {
    tasks=$(load_tasks)
    task=$(echo "$tasks" | jq --arg id "$1" '.[] | select(.id == ($id|tonumber))')
    if [ -z "$task" ]; then
        echo "No task with ID $1" >&2
        exit 1
    fi
    echo "$task" | jq
}

# Function to list tasks
list_tasks() {
    today=$(date +%F)
    completed=$(load_tasks | jq --arg date "$1" '[.[] | select(.due_date == $date and .completion == true)]')
    uncompleted=$(load_tasks | jq --arg date "$1" '[.[] | select(.due_date == $date and .completion == false)]')
    echo "Completed Tasks:"
    echo "$completed" | jq
    echo "Uncompleted Tasks:"
    echo "$uncompleted" | jq
}

# Function to search for tasks by title
search_task() {
    tasks=$(load_tasks)
    matches=$(echo "$tasks" | jq --arg title "$1" '[.[] | select(.title | contains($title))]')
    echo "$matches" | jq
}

# Main script logic
case "$1" in
    create)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 create <title> <due_date> [description] [location]"
            exit 1
        fi
        create_task "$2" "$3" "$4" "$5"
        ;;
    update)
        if [ -z "$2" ]; then
            echo "Usage: $0 update <id> [title] [due_date] [description] [location] [completion]"
            exit 1
        fi
        update_task "$2" "$3" "$4" "$5" "$6" "$7"
        ;;
    delete)
        if [ -z "$2" ]; then
            echo "Usage: $0 delete <id>"
            exit 1
        fi
        delete_task "$2"
        ;;
    show)
        if [ -z "$2" ]; then
            echo "Usage: $0 show <id>"
            exit 1
        fi
        show_task "$2"
        ;;
    list)
        list_tasks "${2:-$(date +%F)}"
        ;;
    search)
        if [ -z "$2" ]; then
            echo "Usage: $0 search <title>"
            exit 1
        fi
        search_task "$2"
        ;;
    *)
        list_tasks "$(date +%F)"
        ;;
esac

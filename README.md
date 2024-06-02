# Todo Task Manager Script

## Usage

The script supports the following commands:

- `create <title> <due_date> [description] [location]`
- `update <id> [title] [due_date] [description] [location] [completion]`
- `delete <id>`
- `show <id>`
- `list [date]`
- `search <title>`

### Commands
Update a Task
./todo.sh update <id> "New Title" "2024-07-01" "New Description" "New Location" true

Delete a Task
./todo.sh delete <id>


Show a Task
./todo.sh show <id>


Search Tasks
Search Tasks


#### Create a Task

```sh
./todo.sh create "Task Title" "2024-06-30" "Description" "Location"

# ===============================
# Student Management System (Bash)
# With Colored Output
# ===============================

# Define Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
MAGENTA="\e[35m"
WHITE="\e[97m"
RESET="\e[0m"

# Data file to store student records
DATA_FILE="student_records.txt"

# Teacher Credentials
TEACHER_USERNAME="teacher"
TEACHER_PASSWORD="fast123"

# Function to calculate grade based on marks
calculate_grade() {
    marks=$1
    if [ $marks -ge 90 ]; then echo "A";
    elif [ $marks -ge 80 ]; then echo "B";
    elif [ $marks -ge 70 ]; then echo "C";
    elif [ $marks -ge 60 ]; then echo "D";
    else echo "F";
    fi
}

# Function to convert grade to CGPA
grade_to_cgpa() {
    grade=$1
    case $grade in
        A) echo "4.0";;
        B) echo "3.0";;
        C) echo "2.0";;
        D) echo "1.0";;
        F) echo "0.0";;
        *) echo "0.0";;
    esac
}

# Function to save student data to file
save_student() {
    echo "$1,$2,$3,$4,$5" >> $DATA_FILE
}

# Function to initialize student records file
load_students() {
    if [ ! -f $DATA_FILE ]; then
        touch $DATA_FILE
    fi
}

# Function to add a student
add_student() {
    echo -e "${MAGENTA}Enter Roll Number: ${RESET}"
    read roll
    echo -e "${MAGENTA}Enter Name: ${RESET}"
    read name
    echo -e "${MAGENTA}Enter Marks: ${RESET}"
    read marks
    grade=$(calculate_grade "$marks")
    cgpa=$(grade_to_cgpa "$grade")
    save_student "$roll" "$name" "$marks" "$grade" "$cgpa"
    echo -e "${GREEN}Student added successfully!${RESET}"
}

# Function to delete a student
delete_student() {
    echo -e "${MAGENTA}Enter Roll Number to delete: ${RESET}"
    read roll
    grep -v "^$roll," "$DATA_FILE" > temp && mv temp "$DATA_FILE"
    echo -e "${RED}Student record deleted if existed.${RESET}"
}

# Function to assign or update marks for a student
assign_marks() {
    echo -e "${MAGENTA}Enter Roll Number to assign marks: ${RESET}"
    read roll
    echo -e "${MAGENTA}Enter new marks: ${RESET}"
    read marks
    grade=$(calculate_grade "$marks")
    cgpa=$(grade_to_cgpa "$grade")

    # Find existing student record
    student=$(grep "^$roll," "$DATA_FILE")
    if [ -z "$student" ]; then
        echo -e "${RED}Student not found!${RESET}"
        return
    fi

    name=$(echo "$student" | cut -d',' -f2)

    # Remove old record and add updated one
    grep -v "^$roll," "$DATA_FILE" > temp && mv temp "$DATA_FILE"
    save_student "$roll" "$name" "$marks" "$grade" "$cgpa"

    echo -e "${GREEN}Marks updated and grades recalculated.${RESET}"
}

# Function to display sorted list of students
list_students_sorted() {
    echo -e "${CYAN}1. Ascending order  2. Descending order${RESET}"
    read choice
    if [ "$choice" -eq 1 ]; then
        sort -t',' -k5 -n "$DATA_FILE" | column -t -s','
    else
        sort -t',' -k5 -nr "$DATA_FILE" | column -t -s','
    fi
}

# Function to display students who passed (CGPA >= 2.0)
list_passed_students() {
    echo -e "${GREEN}Passed Students (CGPA >= 2.0):${RESET}"
    awk -F',' '$5 >= 2.0' "$DATA_FILE" | column -t -s','
}

# Function to display students who failed (CGPA < 2.0)
list_failed_students() {
    echo -e "${RED}Failed Students (CGPA < 2.0):${RESET}"
    awk -F',' '$5 < 2.0' "$DATA_FILE" | column -t -s','
}

# Function to view a student's record
view_student_record() {
    echo -e "${MAGENTA}Enter Roll Number: ${RESET}"
    read roll
    record=$(grep "^$roll," "$DATA_FILE")
    if [ -z "$record" ]; then
        echo -e "${RED}No record found.${RESET}"
    else
        echo -e "${CYAN}Roll No | Name | Marks | Grade | CGPA${RESET}"
        echo "$record" | column -t -s','
    fi
}

# Function for teacher login
teacher_login() {
    echo -e "${MAGENTA}Enter username: ${RESET}"
    read uname
    echo -e "${MAGENTA}Enter password: ${RESET}"
    read -s pass
    
    if [ "$uname" == "$TEACHER_USERNAME" ] && [ "$pass" == "$TEACHER_PASSWORD" ]; then
        echo -e "${GREEN}\nLogin Successful!${RESET}"
        while true; do
            echo -e "${CYAN}\nTeacher Panel:${RESET}"
            echo -e "${WHITE}1. Add Student${RESET}"
            echo -e "${WHITE}2. Delete Student${RESET}"
            echo -e "${WHITE}3. Assign Marks${RESET}"
            echo -e "${WHITE}4. List Passed Students${RESET}"
            echo -e "${WHITE}5. List Failed Students${RESET}"
            echo -e "${WHITE}6. View Student Record${RESET}"
            echo -e "${WHITE}7. List Students (Sort by CGPA)${RESET}"
            echo -e "${WHITE}8. Logout${RESET}"
            read ch
            case $ch in
                1) add_student;;
                2) delete_student;;
                3) assign_marks;;
                4) list_passed_students;;
                5) list_failed_students;;
                6) view_student_record;;
                7) list_students_sorted;;
                8) break;;
                *) echo -e "${RED}Invalid choice${RESET}";;
            esac
        done
    else
        echo -e "${RED}Invalid credentials!${RESET}"
    fi
}

# Function for student login
student_login() {
    echo -e "${MAGENTA}Enter your Roll Number: ${RESET}"
    read roll
    student=$(grep "^$roll," "$DATA_FILE")
    if [ -z "$student" ]; then
        echo -e "${RED}Student not found!${RESET}"
        return
    fi

    name=$(echo "$student" | cut -d',' -f2)
    marks=$(echo "$student" | cut -d',' -f3)
    grade=$(echo "$student" | cut -d',' -f4)
    cgpa=$(echo "$student" | cut -d',' -f5)

    while true; do
        echo -e "${CYAN}\nStudent Panel:${RESET}"
        echo -e "${WHITE}1. View Grades${RESET}"
        echo -e "${WHITE}2. View CGPA${RESET}"
        echo -e "${WHITE}3. Logout${RESET}"
        read ch
        case $ch in
            1) echo -e "${GREEN}Your Grade: $grade${RESET}";;
            2) echo -e "${GREEN}Your CGPA: $cgpa${RESET}";;
            3) break;;
            *) echo -e "${RED}Invalid choice${RESET}";;
        esac
    done
}

# Main menu function
main_menu() {
    load_students
    while true; do
        echo -e "\n${CYAN}===== Student Management System =====${RESET}"
        echo -e "${YELLOW}1. Teacher Login${RESET}"
        echo -e "${YELLOW}2. Student Login${RESET}"
        echo -e "${YELLOW}3. Exit${RESET}"
        read choice
        case $choice in
            1) teacher_login;;
            2) student_login;;
            3) echo -e "${RED}Exiting...${RESET}"; break;;
            *) echo -e "${RED}Invalid option, please try again.${RESET}";;
        esac
    done
}

# Run the program
main_menu
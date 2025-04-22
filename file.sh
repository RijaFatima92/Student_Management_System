#!/bin/bash

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
    if [ $marks -ge 90 ]; then echo "A"
    elif [ $marks -ge 80 ]; then echo "B"
    elif [ $marks -ge 70 ]; then echo "C"
    elif [ $marks -ge 60 ]; then echo "D"
    else echo "F"
    fi
}

# Function to convert grade to CGPA
grade_to_cgpa() {
    grade=$1
    case $grade in
        A) echo "4.0" ;;
        B) echo "3.0" ;;
        C) echo "2.0" ;;
        D) echo "1.0" ;;
        F) echo "0.0" ;;
        *) echo "0.0" ;;
    esac
}

# Function to save student data to file
save_student() {
    echo "$1,$2,$3,$4,$5" >> "$DATA_FILE"
}

# Function to initialize student records file
load_students() {
    if [ ! -f "$DATA_FILE" ]; then
        echo -e "${RED}Error: Student records file not found! Creating a new one...${RESET}"
        touch "$DATA_FILE"
    fi
}

# Function to add a student
add_student() {
    while true; do
        echo -e "${MAGENTA}Enter Roll Number (format: 23F-0781): ${RESET}"
        read roll
        if [[ ! "$roll" =~ ^[0-9]{2}F-[0-9]{4}$ ]]; then
            echo -e "${RED}Invalid Roll Number format! Use format like 23F-0781.${RESET}"
        elif grep -q "^$roll," "$DATA_FILE"; then
            echo -e "${RED}Error: Student with Roll Number $roll already exists.${RESET}"
        else
            break
        fi
    done

    while true; do
        echo -e "${MAGENTA}Enter Name: ${RESET}"
        read name
        if [[ -z "$name" || "$name" =~ ^- || "$name" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Invalid Name! It cannot be empty, start with '-' or be only numbers.${RESET}"
        else
            break
        fi
    done

    while true; do
        echo -e "${MAGENTA}Enter Marks (1-100): ${RESET}"
        read marks
        if ! [[ "$marks" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Invalid input! Marks must be a number.${RESET}"
        elif [ "$marks" -lt 1 ] || [ "$marks" -gt 100 ]; then
            echo -e "${RED}Marks must be between 1 and 100.${RESET}"
        else
            break
        fi
    done

    grade=$(calculate_grade "$marks")
    cgpa=$(grade_to_cgpa "$grade")
    save_student "$roll" "$name" "$marks" "$grade" "$cgpa"
    echo -e "${GREEN}Student added successfully!${RESET}"
}

# Function to delete a student
delete_student() {
    echo -e "${MAGENTA}Enter Roll Number to delete: ${RESET}"
    read roll

    if [[ ! "$roll" =~ ^[0-9]{2}F-[0-9]{4}$ ]]; then
        echo -e "${RED}Invalid Roll Number format!${RESET}"
        return
    fi

    if grep "^$roll," "$DATA_FILE" > /dev/null; then
        grep -v "^$roll," "$DATA_FILE" > temp && mv temp "$DATA_FILE"
        echo -e "${GREEN}Student record deleted successfully.${RESET}"
    else
        echo -e "${RED}Error: No record found for Roll Number ${roll}.${RESET}"
    fi
}

# Function to assign marks
assign_marks() {
    echo -e "${MAGENTA}Enter Roll Number to assign marks: ${RESET}"
    read roll

    if [[ ! "$roll" =~ ^[0-9]{2}F-[0-9]{4}$ ]]; then
        echo -e "${RED}Invalid Roll Number format!${RESET}"
        return
    fi

    student=$(grep "^$roll," "$DATA_FILE")
    if [ -z "$student" ]; then
        echo -e "${RED}Error: No student found with Roll Number ${roll}.${RESET}"
        return
    fi

    echo -e "${MAGENTA}Enter new marks (1-100): ${RESET}"
    read marks
    if ! [[ "$marks" =~ ^[0-9]+$ && "$marks" -ge 1 && "$marks" -le 100 ]]; then
        echo -e "${RED}Invalid Marks!${RESET}"
        return
    fi

    name=$(echo "$student" | cut -d',' -f2)
    grade=$(calculate_grade "$marks")
    cgpa=$(grade_to_cgpa "$grade")

    grep -v "^$roll," "$DATA_FILE" > temp && mv temp "$DATA_FILE"
    save_student "$roll" "$name" "$marks" "$grade" "$cgpa"

    echo -e "${GREEN}Marks updated and grades recalculated.${RESET}"
}

# Function to view sorted list
list_students_sorted() {
    while true; do
        echo -e "${CYAN}1. Ascending order  2. Descending order${RESET}"
        read choice
        if [ "$choice" -eq 1 ]; then
            sort -t',' -k5 -n "$DATA_FILE" | column -t -s','
            break
        elif [ "$choice" -eq 2 ]; then
            sort -t',' -k5 -nr "$DATA_FILE" | column -t -s','
            break
        else
            echo -e "${RED}Invalid choice! Please enter 1 for Ascending or 2 for Descending.${RESET}"
        fi
    done
}

list_passed_students() {
    echo -e "${GREEN}Passed Students (CGPA >= 2.0):${RESET}"
    awk -F',' '$5 >= 2.0' "$DATA_FILE" | column -t -s','
}

list_failed_students() {
    echo -e "${RED}Failed Students (CGPA < 2.0):${RESET}"
    awk -F',' '$5 < 2.0' "$DATA_FILE" | column -t -s','
}

view_student_record() {
    echo -e "${MAGENTA}Enter Roll Number to view record: ${RESET}"
    read roll

    if [[ ! "$roll" =~ ^[0-9]{2}F-[0-9]{4}$ ]]; then
        echo -e "${RED}Invalid Roll Number format!${RESET}"
        return
    fi

    record=$(grep "^$roll," "$DATA_FILE")
    if [ -z "$record" ]; then
        echo -e "${RED}No student found with Roll Number $roll.${RESET}"
    else
        echo -e "${CYAN}Roll No | Name | Marks | Grade | CGPA${RESET}"
        echo "$record" | column -t -s','
    fi
}

teacher_login() {
    echo -e "${MAGENTA}Enter username: ${RESET}"
    read uname
    echo -e "${MAGENTA}Enter password: ${RESET}"
    read -s pass

    if [ "$uname" == "$TEACHER_USERNAME" ] && [ "$pass" == "$TEACHER_PASSWORD" ]; then
        echo -e "${GREEN}Login Successful!${RESET}"
        while true; do
            echo -e "\n${CYAN}Teacher Panel:${RESET}"
            echo -e "${WHITE}1. Add Student"
            echo -e "2. Delete Student"
            echo -e "3. Assign Marks"
            echo -e "4. List Passed Students"
            echo -e "5. List Failed Students"
            echo -e "6. View Student Record"
            echo -e "7. List Students (Sorted)"
            echo -e "8. Logout${RESET}"
            read ch
            case $ch in
                1) add_student ;;
                2) delete_student ;;
                3) assign_marks ;;
                4) list_passed_students ;;
                5) list_failed_students ;;
                6) view_student_record ;;
                7) list_students_sorted ;;
                8) break ;;
                *) echo -e "${RED}Invalid choice${RESET}" ;;
            esac
        done
    else
        echo -e "${RED}Invalid credentials!${RESET}"
    fi
}

student_login() {
    echo -e "${MAGENTA}Enter your Roll Number: ${RESET}"
    read roll

    if [[ ! "$roll" =~ ^[0-9]{2}F-[0-9]{4}$ ]]; then
        echo -e "${RED}Invalid Roll Number format!${RESET}"
        return
    fi

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
        echo -e "\n${CYAN}Student Panel:${RESET}"
        echo -e "${WHITE}1. View Grades"
        echo -e "2. View CGPA"
        echo -e "3. Logout${RESET}"
        read ch
        case $ch in
            1) echo -e "${GREEN}Your Grade: $grade${RESET}" ;;
            2) echo -e "${GREEN}Your CGPA: $cgpa${RESET}" ;;
            3) break ;;
            *) echo -e "${RED}Invalid choice${RESET}" ;;
        esac
    done
}

# Main Menu
main_menu() {
    load_students
    while true; do
        echo -e "\n${CYAN}===== Student Management System =====${RESET}"
        echo -e "${YELLOW}1. Teacher Login"
        echo -e "2. Student Login"
        echo -e "3. Exit${RESET}"
        read choice
        case $choice in
            1) teacher_login ;;
            2) student_login ;;
            3) echo -e "${RED}Exiting...${RESET}"; break ;;
            *) echo -e "${RED}Invalid option, try again.${RESET}" ;;
        esac
    done
}

# Run the Program
main_menu
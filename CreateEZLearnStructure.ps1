# Define the base directory for the EZLearn School file structure
$baseDirectory = "C:\Users\mnyuy\OneDrive\Desktop\ezlearngitlab\EZLearn_School"

# Define classes and courses
$classes = @('Form_1', 'Form_2', 'Form_3', 'Form_4', "Form_5")
$courses = @('Mathematics', 'Science', 'English', 'History', 'Geography', "literture")

# Define a list of first and last names (Add more names or change as needed)
$firstNames = @('Alex', 'Jordan', 'Taylor', 'Morgan', 'Casey', 'Jamie', 'Riley', 'Quinn', 'Skyler', 'Drew')
$lastNames = @('Smith', 'Amos', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Cho', 'Moore', 'Taylor')

# Create the Classes directory and subdirectories
$classes | ForEach-Object {
    $classDir = Join-Path -Path $baseDirectory -ChildPath "Classes\$_"
    $studentDir = Join-Path -Path $classDir -ChildPath "Students"
    $coursesDir = Join-Path -Path $classDir -ChildPath "Courses"
    
    # Create directories for each class
    New-Item -ItemType Directory -Path $classDir -Force
    New-Item -ItemType Directory -Path $studentDir -Force
    New-Item -ItemType Directory -Path $coursesDir -Force
    
    # Create student directories with two names and course subdirectories
    1..5 | ForEach-Object {
        $firstName = $firstNames | Get-Random
        $lastName = $lastNames | Get-Random
        $studentFullName = "$firstName $lastName"
        $individualStudentDir = Join-Path -Path $studentDir -ChildPath "$studentFullName"
        New-Item -ItemType Directory -Path $individualStudentDir -Force
        $courses | ForEach-Object {
            New-Item -ItemType Directory -Path (Join-Path -Path $individualStudentDir -ChildPath $_) -Force
        }
    }

    # Create course directories with standard subdirectories
    $courses | ForEach-Object {
        $courseDir = Join-Path -Path $coursesDir -ChildPath $_
        New-Item -ItemType Directory -Path $courseDir -Force
        New-Item -ItemType Directory -Path (Join-Path -Path $courseDir -ChildPath "Lessons") -Force
        New-Item -ItemType Directory -Path (Join-Path -Path $courseDir -ChildPath "Assignments") -Force
        New-Item -ItemType Directory -Path (Join-Path -Path $courseDir -ChildPath "Exams") -Force
    }
}

# Create Administration directory and subdirectories
$adminDir = Join-Path -Path $baseDirectory -ChildPath "Administration"
$staffDir = Join-Path -Path $adminDir -ChildPath "Staff"
$policyDir = Join-Path -Path $adminDir -ChildPath "Policies"
$reportDir = Join-Path -Path $adminDir -ChildPath "Reports"

New-Item -ItemType Directory -Path $adminDir -Force
New-Item -ItemType Directory -Path $staffDir -Force
New-Item -ItemType Directory -Path $policyDir -Force
New-Item -ItemType Directory -Path $reportDir -Force

# Add more directories as needed for extracurricular activities, library, etc., using similar New-Item commands

Write-Output "EZLearn School directory structure has been created at $baseDirectory"

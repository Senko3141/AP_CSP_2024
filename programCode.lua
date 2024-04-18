-- AP Computer Science: Performance Task
-- personalGradebook

--[[
	** ACKNOWLEDGEMENTS **
		- Code written using Lua (ROBLOX STUDIO's programming language)
		- ROBLOX STUDIO | Used to create the program, and user interface
		
	--------------------------------------------------------------------------

	Used to add/remove assignments and their grades based on the inputs given
		(studentName: string, assignemtName: string, grade: number)
	
	Gradeboook Template:
		gradebook[studentName] = {
			[1] = {assignmentName = "a", grade = 0,},
			[2] = {assignmentName = "b", grade = 0,},
		}
	
	**User Input** is provided through the keyboard, through the interacting with the interface shown in the video
	**Output** is shown through the gradebook taking a physical form/interactable form, shown in the video
	
	Procedures (student-developed):
		CORE PROGRAM: getAssignment, getLength, createNewGrade, removeAssignment, updateGrade
		USER INTERFACE: updateGradeList, updateStudentsList
	
	List: gradeBook
		- Used to store all data for students and their grades
]]
local gradebook = {}

-- CORE OF PROGRAM
local function getLength(list) --Returns (number); returns the length of a list
	local count = 0
	for _,v in pairs(list) do
		count += 1
	end
	return count
end
local function getAssignment(list, name: string) --Returns (number); used to find the index of a given assignment
	-- algorithm

	local index = 1
	while index <= getLength(list) do
		local data = list[index]
		if data.assignmentName == name then
			return index
		end
		index += 1
	end
	
	return nil
end
local function createNewGrade(studentName: string, assignmentName: string, grade: number)
	--procedureName: createNewGrade
	--description: Procedure used to create a new grade w/ the given inputs
	--parameters: studentName (string), assignmentName (string), grade (number)
	--returnType: nil 
	
	if not (gradebook[studentName]) then
		-- Add Student to Gradebook
		gradebook[studentName] = {}
	end
	local length = getLength(gradebook[studentName])+1
	
	if getAssignment(gradebook[studentName], assignmentName) then
		-- found duplicate assignment in student gradebook
		warn("There is already an assignment called ".. assignmentName.." in ".. studentName.."'s gradebook")
		return
	end
	
	-- Creating assignment with grade
	gradebook[studentName][length] = {
		["assignmentName"] = assignmentName,
		["grade"] = grade,
	}
end
local function removeAssignment(studentName: string, assignmentName: string)
	--Procedure used to remove a specificed grade from the given inputs
	--Returns nil
	
	if not (gradebook[studentName]) then
		print(studentName.. " was not found in the gradebook")
		return
	end
	local foundGrade = getAssignment(gradebook[studentName], assignmentName)
	if foundGrade then
		-- Removing Grade
		
		local lengthBeforeRemoval = getLength(gradebook[studentName])
		
		gradebook[studentName][foundGrade] = nil
		
		-- Shifting list
		if lengthBeforeRemoval > 0 then
			for i = foundGrade, lengthBeforeRemoval do
				gradebook[studentName][i] = gradebook[studentName][i+1]
			end
		end
		--
	end
end
local function updateGrade(studentName: string, assignmentName: string, newGrade: number)
	--Procedure to update the grade of an assignment for a student
	--Returns nil
	if not gradebook[studentName] then 
		print(studentName.. " was not found in the gradebook")
		return
	end
	local gradeIndex = getAssignment(gradebook[studentName], assignmentName)
	if gradeIndex then
		local gradeData = gradebook[studentName][gradeIndex]
		gradeData.grade = newGrade
		print("Successfully updated ".. studentName.."s grade for ".. assignmentName.." to ".. newGrade)
	end
end


-- USER INTERFACE SETUP
local mainUI = script.Parent
local root = mainUI:WaitForChild("Root")

local mainFrame = root.Main
local otherFrame = root.Other
local gradeDataFrame = root.Sub
local changeFrame = root["Remove/Change"]

-- Defaulting
changeFrame.Visible = false
for _,v in pairs(gradeDataFrame.Grades:GetChildren()) do
	if v:IsA("Frame") then v:Destroy() end
end
for _,v in pairs(mainFrame.Students:GetChildren()) do
	if v:IsA("Frame") then v:Destroy() end
end

-- userInterface Functions
local currentStudent = nil
local currentAssignment = nil

local function updateGradeList(studentName, grades)
	for _,v in pairs(gradeDataFrame.Grades:GetChildren()) do
		if v:IsA("Frame") then v:Destroy() end
	end
	changeFrame.Visible = false
	
	if not studentName or not grades then return end
	
	currentStudent = studentName	
	gradeDataFrame.Title.Text = "STUDENT GRADES ("..studentName..")"
	
	for index, data in ipairs(grades) do
		local clone = script.gradeTemplate:Clone()
		clone.Name = index
		clone.assignmentName.Text = data.assignmentName
		clone.grade.Text = data.grade.."%"
		
		clone.assignmentName.MouseButton1Click:Connect(function()
			currentAssignment = clone.assignmentName.Text
			changeFrame.Visible = true
		end)
		
		clone.Parent = gradeDataFrame.Grades
	end
end
local function updateStudentsList()
	for _,v in pairs(mainFrame.Students:GetChildren()) do
		if v:IsA("Frame") then v:Destroy() end
	end
	for studentName, grades in pairs(gradebook) do
		local clone = script.studentTemplate:Clone()
		clone.Name = studentName
		clone.studentName.Text = studentName
		clone.viewGrades.MouseButton1Click:Connect(function()
			updateGradeList(studentName, grades)
		end)
		clone.Parent = mainFrame.Students
	end
end

-- Adding Students
otherFrame.addStudent.MouseButton1Click:Connect(function()
	-- Automatically Display the Student's Grade if the student is already there
	-- upgdateGradeList (function that updates the userInterface)
	
	if gradebook[otherFrame.studentNameBox.Text] then
		createNewGrade(otherFrame.studentNameBox.Text, otherFrame.assignmentBox.Text, otherFrame.gradeBox.Text)
		updateGradeList(otherFrame.studentNameBox.Text, gradebook[otherFrame.studentNameBox.Text])
	else
		-- Don't display, simply create new grade
		createNewGrade(otherFrame.studentNameBox.Text, otherFrame.assignmentBox.Text, otherFrame.gradeBox.Text)
	end
	updateStudentsList()
end)
-- Changing/Removing Grade
changeFrame.changeGrade.MouseButton1Click:Connect(function()
	if currentStudent and currentAssignment then
		local newGrade = changeFrame.gradeBox.Text
		updateGrade(currentStudent, currentAssignment, newGrade)
		updateGradeList(currentStudent, gradebook[currentStudent])
		currentAssignment = nil
	end
end)
changeFrame.removeGrade.MouseButton1Click:Connect(function()
	removeAssignment(currentStudent, currentAssignment)
	updateGradeList(currentStudent, gradebook[currentStudent])
	currentAssignment = nil
end)

--[[

** DEBUG TESTING **

createNewGrade("Brady", "Trigonometry Test", 100)
createNewGrade("Brady", "Unit Circle Test", 91)
createNewGrade("Brady", "Unit Circle Test", 100)

createNewGrade("Bobby", "Trigonometry Test", 89)
--
updateGrade("Bobby", "Trigonometry Test", 100)
--
removeAssignment("Brady", "Trigonometry Test")

print(gradebook)
]]
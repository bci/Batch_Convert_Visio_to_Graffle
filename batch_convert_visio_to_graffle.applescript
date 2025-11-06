-- batch_convert_visio_to_graffle.applescript
-- Recursively processes all .vss and .vssx files from VisioStencils,
-- opens each in OmniGraffle, and saves to OmniGraffle's iCloud stencils folder.
-- Usage: osascript batch_convert_visio_to_graffle.applescript [--overwrite|--skip] [--debuglevel info|warning|error|debug] [--quit-interval <number>]

-- Logging handler
on logMessage(level, msg, priority, debugPriority)
	if priority >= debugPriority then
		log "[" & level & "] " & msg
	end if
end logMessage

on run argv
	-- Parse command line arguments
	set overwriteMode to missing value
	set debugLevel to "info" -- default
	set quitInterval to 50 -- default
	set visioStencilsDir to missing value -- will default to ./VisioStencils
	set maxCount to missing value -- no limit by default
	
	-- Check for help flag first
	repeat with arg in argv
		if (arg as text) is "--help" or (arg as text) is "-h" then
			set helpLines to {"Usage: osascript batch_convert_visio_to_graffle.applescript [OPTIONS]", "", "Recursively converts Visio stencils (.vss, .vssx) to OmniGraffle stencils.", "", "Required options:", "  --overwrite                Overwrite existing stencils", "  --skip                     Skip files that already exist", "", "Optional options:", "  --visio-stencil-folder DIR Input folder containing Visio stencils (default: ./VisioStencils)", "  --debuglevel LEVEL         Set logging level: debug, info, warning, error (default: info)", "  --quit-interval NUM        Quit OmniGraffle every NUM files to free memory (default: 50)", "  --count NUM                Limit number of files to convert (useful for testing)", "  --help, -h                 Display this help message", "", "Examples:", "  osascript batch_convert_visio_to_graffle.applescript --skip", "  osascript batch_convert_visio_to_graffle.applescript --overwrite --debuglevel debug", "  osascript batch_convert_visio_to_graffle.applescript --skip --count 5", "  osascript batch_convert_visio_to_graffle.applescript --skip --visio-stencil-folder ~/MyStencils", "  osascript batch_convert_visio_to_graffle.applescript --skip --quit-interval 25"}
			repeat with helpLine in helpLines
				log helpLine
			end repeat
			return ""
		end if
	end repeat
	
	-- Parse arguments
	set skipNext to false
	repeat with i from 1 to count of argv
		if skipNext then
			set skipNext to false
		else
			set arg to item i of argv
			if arg is "--overwrite" then
				set overwriteMode to true
			else if arg is "--skip" then
				set overwriteMode to false
			else if arg is "--debuglevel" then
				-- Next argument should be the level
				if i < (count of argv) then
					set debugLevel to item (i + 1) of argv
					if debugLevel is not in {"info", "warning", "error", "debug"} then
						display dialog "Invalid debug level. Use info, warning, error, or debug" buttons {"OK"} default button "OK"
						return "ERROR: Invalid debug level"
					end if
					set skipNext to true
				end if
			else if arg is "--quit-interval" then
				-- Next argument should be the number
				if i < (count of argv) then
					set quitInterval to (item (i + 1) of argv) as integer
					if quitInterval < 1 then
						display dialog "Quit interval must be at least 1" buttons {"OK"} default button "OK"
						return "ERROR: Invalid quit interval"
					end if
					set skipNext to true
				end if
			else if arg is "--visio-stencil-folder" then
				-- Next argument should be the folder path
				if i < (count of argv) then
					set visioStencilsDir to item (i + 1) of argv
					set skipNext to true
				end if
			else if arg is "--count" then
				-- Next argument should be the number
				if i < (count of argv) then
					set maxCount to (item (i + 1) of argv) as integer
					if maxCount < 1 then
						display dialog "Count must be at least 1" buttons {"OK"} default button "OK"
						return "ERROR: Invalid count"
					end if
					set skipNext to true
				end if
			end if
		end if
	end repeat
	
	-- Validate required arguments
	if overwriteMode is missing value then
		display dialog "Missing argument. Use --overwrite to replace existing files or --skip to skip them." buttons {"OK"} default button "OK"
		return "ERROR: Missing argument. Use --overwrite or --skip"
	end if
	
	-- Map debug levels to numeric priority (lower = more verbose)
	if debugLevel is "debug" then
		set debugPriority to 0
	else if debugLevel is "info" then
		set debugPriority to 1
	else if debugLevel is "warning" then
		set debugPriority to 2
	else if debugLevel is "error" then
		set debugPriority to 3
	end if
	set scriptDir to do shell script "dirname " & quoted form of POSIX path of (path to me)
	set scriptDir to do shell script "cd " & quoted form of scriptDir & " && pwd"
	
	-- Set default visioStencilsDir if not provided
	if visioStencilsDir is missing value then
		set visioDir to scriptDir & "/VisioStencils"
	else
		-- Expand relative paths and tildes
		set visioDir to do shell script "cd " & quoted form of visioStencilsDir & " 2>/dev/null && pwd || echo ''"
		if visioDir is "" then
			set errorMsg to "ERROR: Visio stencil folder not found: " & visioStencilsDir
			display dialog errorMsg buttons {"OK"} default button "OK" with icon stop
			error errorMsg
		end if
	end if
	
	-- Validate that the input folder exists
	set folderExists to do shell script "test -d " & quoted form of visioDir & " && echo 'YES' || echo 'NO'"
	if folderExists is "NO" then
		set errorMsg to "ERROR: Visio stencil folder not found: " & visioDir
		display dialog errorMsg buttons {"OK"} default button "OK" with icon stop
		error errorMsg
	end if
	
	-- Validate that the folder contains at least one .vss or .vssx file
	set fileCount to do shell script "find " & quoted form of visioDir & " -type f \\( -iname '*.vss' -o -iname '*.vssx' \\) | wc -l | tr -d ' '"
	if fileCount is "0" then
		set errorMsg to "ERROR: No .vss or .vssx files found in: " & visioDir
		display dialog errorMsg buttons {"OK"} default button "OK" with icon stop
		error errorMsg
	end if
	
	my logMessage("INFO", "Starting batch conversion", 1, debugPriority)
	my logMessage("INFO", "Overwrite mode: " & overwriteMode, 1, debugPriority)
	my logMessage("INFO", "Debug level: " & debugLevel, 1, debugPriority)
	my logMessage("INFO", "Quit interval: " & quitInterval, 1, debugPriority)
	if maxCount is not missing value then
		my logMessage("INFO", "Max count: " & maxCount, 1, debugPriority)
	end if
	
	my logMessage("DEBUG", "VisioStencils directory: " & visioDir, 0, debugPriority)
	
	-- Find all .vss and .vssx files recursively
	set fileList to paragraphs of (do shell script "find " & quoted form of visioDir & " -type f \\( -iname '*.vss' -o -iname '*.vssx' \\)")
	
	set totalFiles to count of fileList
	set processedCount to 0
	set skippedCount to 0
	set errorList to {}
	
	-- OmniGraffle's iCloud stencils directory
	set omniStencilsDir to (POSIX path of (path to home folder)) & "Library/Mobile Documents/iCloud~com~omnigroup~OmniGraffle/Documents/Stencils"
	
	-- Verify iCloud folder exists
	set folderExists to do shell script "test -d " & quoted form of omniStencilsDir & " && echo 'YES' || echo 'NO'"
	if folderExists is "NO" then
		set errorMsg to "ERROR: OmniGraffle iCloud stencils folder not found at: " & omniStencilsDir & return & return & "Expected location: iCloud Drive/OmniGraffle/Stencils" & return & return & "Please ensure OmniGraffle is configured to use iCloud Drive for stencils."
		display dialog errorMsg buttons {"OK"} default button "OK" with icon stop
		error errorMsg
	end if
	
	my logMessage("INFO", "Found " & totalFiles & " files to process", 1, debugPriority)
	my logMessage("DEBUG", "OmniGraffle stencils directory: " & omniStencilsDir, 0, debugPriority)
	
	repeat with visioFile in fileList
		if visioFile is not "" then
			set processedCount to processedCount + 1
			
			-- Stop if we've reached maxCount
			if maxCount is not missing value and processedCount > maxCount then
				my logMessage("INFO", "Reached maximum count of " & maxCount & " files", 1, debugPriority)
				exit repeat
			end if
			
			try
				my logMessage("DEBUG", "Processing file: " & visioFile, 0, debugPriority)
				
				-- Get the folder name and base filename
				set folderName to do shell script "basename " & quoted form of (do shell script "dirname " & quoted form of visioFile)
				set origName to do shell script "basename " & quoted form of visioFile & " | sed -E 's/\\.[^.]+$//'"
				
				-- Sanitize folder name and filename (replace slashes and other invalid characters with _, collapse multiple _)
				set folderName to do shell script "echo " & quoted form of folderName & " | sed -E 's/[/\\\\()]/_/g' | sed -E 's/[^a-zA-Z0-9._-]/_/g' | sed -E 's/_+/_/g'"
				set origName to do shell script "echo " & quoted form of origName & " | sed -E 's/[/\\\\()]/_/g' | sed -E 's/[^a-zA-Z0-9._-]/_/g' | sed -E 's/_+/_/g'"
				
				-- Create stencil name as <folder-name>-<filename>
				set stencilName to folderName & "-" & origName
				set savedStencilPath to omniStencilsDir & "/" & stencilName & ".gstencil"
				
				my logMessage("DEBUG", "Sanitized stencil name: " & stencilName, 0, debugPriority)
				
				-- Check if destination already exists
				set fileExists to do shell script "test -e " & quoted form of savedStencilPath & " && echo 'YES' || echo 'NO'"
				
				if fileExists is "YES" then
					if overwriteMode is false then
						-- Skip mode: don't process this file
						set skippedCount to skippedCount + 1
						my logMessage("INFO", "[" & processedCount & "/" & totalFiles & "] SKIP (exists): " & visioFile, 1, debugPriority)
					else
						-- Overwrite mode: delete existing file first
						my logMessage("WARNING", "[" & processedCount & "/" & totalFiles & "] Deleting existing: " & savedStencilPath, 2, debugPriority)
						do shell script "rm -rf " & quoted form of savedStencilPath
						-- Continue to process the file below
					end if
				end if
				
				-- Only process if we're not skipping
				if fileExists is "NO" or overwriteMode is true then
					my logMessage("DEBUG", "Opening file in OmniGraffle", 0, debugPriority)
					-- Use 'open' command to open in OmniGraffle (like double-clicking)
					do shell script "open -a OmniGraffle " & quoted form of visioFile
					delay 3.0
					
					my logMessage("DEBUG", "Setting stencil name via GUI", 0, debugPriority)
					-- Save stencil dialog opens automatically - just set the name
					tell application "System Events"
						tell process "OmniGraffle"
							delay 1.0
							
							-- Set stencil name - select all and replace
							keystroke "a" using {command down}
							delay 0.2
							do shell script "echo " & quoted form of stencilName & " | tr -d '\\n' | pbcopy"
							keystroke "v" using {command down}
							delay 0.5
							
							-- Save (press Return)
							keystroke return
							delay 1.5
							
						-- If overwrite mode and dialog appears, handle Replace
						if overwriteMode is true then
							try
								my logMessage("DEBUG", "Clicking Replace button if present", 0, debugPriority)
									click button "Replace" of sheet 1 of window 1
									delay 0.5
								end try
							end if
							
							-- Close the document (Cmd+W)
							keystroke "w" using {command down}
							delay 0.5
						end tell
					end tell
					
					-- Verify the file was created in OmniGraffle's iCloud stencils folder
					delay 1.0
					set fileExists to do shell script "test -e " & quoted form of savedStencilPath & " && echo 'YES' || echo 'NO'"
					if fileExists is not "YES" then
						error "Output file was not created: " & savedStencilPath
					end if
					
					my logMessage("INFO", "[" & processedCount & "/" & totalFiles & "] OK: " & visioFile & " -> " & savedStencilPath, 1, debugPriority)
				end if
				
				-- Periodically quit OmniGraffle to free memory
				if processedCount mod quitInterval is 0 then
					my logMessage("INFO", "Quitting OmniGraffle to free memory (after " & processedCount & " files)", 1, debugPriority)
					tell application "OmniGraffle"
						quit
					end tell
					delay 2.0
				end if
				
			on error errMsg
				set end of errorList to "[" & processedCount & "/" & totalFiles & "] ERR: " & visioFile & " - " & errMsg
				my logMessage("ERROR", "[" & processedCount & "/" & totalFiles & "] ERR: " & visioFile & " - " & errMsg, 3, debugPriority)
			end try
		end if
	end repeat
	
	-- Summary
	set successCount to totalFiles - (count of errorList) - skippedCount
	set summary to "Conversion complete: " & successCount & " succeeded, " & skippedCount & " skipped, " & (count of errorList) & " failed out of " & totalFiles & " total files."
	
	my logMessage("INFO", summary, 1, debugPriority)
	
	if (count of errorList) > 0 then
		my logMessage("ERROR", "Errors encountered:", 3, debugPriority)
		repeat with errItem in errorList
			my logMessage("ERROR", errItem as string, 3, debugPriority)
		end repeat
	end if
	
	return summary
end run

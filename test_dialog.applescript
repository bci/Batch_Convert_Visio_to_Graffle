-- Test script to inspect OmniGraffle save dialog
tell application "System Events"
	tell process "OmniGraffle"
		log "Windows: " & (count of windows)
		if (count of windows) > 0 then
			log "Window 1: " & (properties of window 1)
			if (count of sheets of window 1) > 0 then
				log "Sheet 1: " & (properties of sheet 1 of window 1)
				log "Sheet 1 UI elements: " & (count of UI elements of sheet 1 of window 1)
				repeat with i from 1 to (count of UI elements of sheet 1 of window 1)
					try
						log "  Element " & i & ": " & (properties of UI element i of sheet 1 of window 1)
					end try
				end repeat
			end if
		end if
	end tell
end tell

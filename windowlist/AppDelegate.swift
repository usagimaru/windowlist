//
//  AppDelegate.swift
//  windowlist
//
//  Created by usagimaru on 2025/10/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	
	// Set any app/process name to filter info
	private var targetProcess: String = "Finder"
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Check & request “Screen Capture” permission
		if CGPreflightScreenCaptureAccess() {
			getWindowInfo(targetProcess)
		}
		else {
			if CGRequestScreenCaptureAccess() {
				getWindowInfo(targetProcess)
			}
		}
		
		// This code jumps to the “Screen Capture” settings.
//		if let screencaptureSetting = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
//			NSWorkspace.shared.open(screencaptureSetting)
//		}
	}
	
	func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
		false
	}
	
	func applicationDidBecomeActive(_ notification: Notification) {
		if CGPreflightScreenCaptureAccess() {
			getWindowInfo(targetProcess)
		}
	}
	
	private func getWindowInfo(_ targetProcessName: String) {
		let options: CGWindowListOption = [
			.optionAll,
			//.optionOnScreenOnly,
			//.excludeDesktopElements,
		]
		if let windowInfoArray = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [Dictionary<CFString, AnyObject>] {
			let windowInfoArray = windowInfoArray.filter {
				let ownerName = $0[kCGWindowOwnerName] as? String
				return ownerName == targetProcessName
			}
			
			guard let firstWindowInfo = windowInfoArray.first
			else {
				print("none")
				return
			}
			
			print("-------------------------")
			
			if let ownerName = firstWindowInfo[kCGWindowOwnerName] as? String,
			   let ownerPID = firstWindowInfo[kCGWindowOwnerPID] as? pid_t
			{
				print("\(ownerName) [\(ownerPID)]")
				print("Window Count: \(windowInfoArray.count)")
			}
			
			for windowInfo in windowInfoArray {
				// We need the permission about “Screen Capture” to get the `kCGWindowName` info.
				
				if let windowNumber = windowInfo[kCGWindowNumber] as? Int,
				   let windowTitle = windowInfo[kCGWindowName] as? String,
				   let windowFrameInfo = windowInfo[kCGWindowBounds] as? [String : Double]
				{
					let windowFrame = CGRect(x: windowFrameInfo["X"] ?? 0,
											 y: windowFrameInfo["Y"] ?? 0,
											 width: windowFrameInfo["Width"] ?? 0,
											 height: windowFrameInfo["Height"] ?? 0)
					
					print("      Number: \(windowNumber)")
					print("       Title: \"\(windowTitle)\"")
					print("       Frame: \(windowFrame)")
					print("- - - - - - - - - - - - -")
				}
			}
		}
	}


}


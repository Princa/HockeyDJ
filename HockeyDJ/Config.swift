//
//  Config.swift
//  HockeyDJ
//
//  Created on 2026-02-16
//
//  Configuration file for API keys and app settings
//

import Foundation

struct Config {
    // MARK: - YouTube Music Configuration
    
    /// YouTube Data API v3 Key
    /// Get your API key from: https://console.cloud.google.com/
    /// 1. Create a new project or select existing
    /// 2. Enable YouTube Data API v3
    /// 3. Create credentials (API Key)
    /// 4. Replace "YOUR_API_KEY_HERE" with your actual key
    static let youtubeAPIKey = "AIzaSyC3NBMdNHMOF_Zf9e4EXkykpWE5c0YtOKQ"
    
    /// YouTube API Base URL
    static let youtubeAPIBaseURL = "https://www.googleapis.com/youtube/v3"
    
    /// Maximum results per API call
    static let maxYouTubeResults = 50
    
    // MARK: - App Configuration
    
    /// App version
    static let appVersion = "1.0.0"
    
    /// App name
    static let appName = "HockeyDJ"
    
    /// Support email
    static let supportEmail = "support@hockeydj.app"
    
    // MARK: - Audio Configuration
    
    /// Default skip forward/backward time (in seconds)
    static let defaultSkipTime: TimeInterval = 10
    
    /// Default fade in duration (in seconds)
    static let defaultFadeInDuration: TimeInterval = 1.0
    
    /// Default fade out duration (in seconds)
    static let defaultFadeOutDuration: TimeInterval = 2.0
    
    // MARK: - Feature Flags
    
    /// Enable YouTube Music integration
    /// Set to false if API key is not configured
    static var isYouTubeMusicEnabled: Bool {
        return youtubeAPIKey != "YOUR_API_KEY_HERE" && !youtubeAPIKey.isEmpty
    }
    
    /// Enable Spotify integration (future feature)
    static let isSpotifyEnabled = false
    
    /// Enable Apple Music integration (future feature)
    static let isAppleMusicEnabled = false
    
    // MARK: - Development Settings
    
    #if DEBUG
    /// Enable debug logging
    static let isDebugMode = true
    
    /// Use sample data for testing
    static let useSampleData = false
    #else
    static let isDebugMode = false
    static let useSampleData = false
    #endif
    
    // MARK: - Helper Methods
    
    /// Check if the app is properly configured
    static func validateConfiguration() -> [String] {
        var issues: [String] = []
        
        if !isYouTubeMusicEnabled {
            issues.append("YouTube API key is not configured. Please update Config.swift with your API key.")
        }
        
        return issues
    }
}

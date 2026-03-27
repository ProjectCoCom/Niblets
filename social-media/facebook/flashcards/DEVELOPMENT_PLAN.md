# Facebook Flashcard Automation - Development Plan

## 1. Executive Summary

This document outlines the development plan for the Facebook Flashcard Automation application, a suite of native desktop applications designed for macOS, Windows, and Linux.

*   **Purpose**: To automate the posting of flashcard content (questions and answers) from CSV files to Facebook Pages.
*   **Target Audience**: Educational content creators, social media managers, and other non-technical users who require a beginner-friendly interface.
*   **Distribution Model**: The application will be a commercial product distributed through Gumroad, utilizing its API for license key verification and subscription management.

## 2. Technology Stack

To ensure the best user experience, performance, and platform integration, this project will use a purely native technology stack for each operating system.

*   **macOS**:
    *   **Language**: Swift
    *   **UI Framework**: SwiftUI
    *   **Data Persistence**: SwiftData
    *   **Background Tasks**: `launchd`
*   **Windows (Future Development)**:
    *   **Language**: C#
    *   **Framework**: .NET with WinUI 3 or WPF
*   **Linux (Future Development)**:
    *   **Language**: C++
    *   **UI Toolkit**: Qt or GTK

**Development Priority**: The initial focus will be on delivering a feature-complete application for **macOS (Apple Silicon)**, followed by macOS (Intel), Windows, and Linux.

## 3. Key Architectural Decisions

*   **Native First**: The user interface and core functionalities will be built using native OS technologies, avoiding cross-platform frameworks to deliver a seamless and high-performance user experience.
*   **Secure by Design**:
    *   **Credential Storage**: All sensitive credentials, such as Facebook access tokens, will be stored securely using the native OS keychain (`macOS Keychain`, `Windows Credential Manager`, `Linux Secret Service`) from the outset.
    *   **Authentication**: The Facebook integration will use a secure OAuth 2.0 flow suitable for public clients (e.g., the Authorization Code Flow with PKCE), which does not expose the application's client secret.
*   **Reliable Background Processing**: Native OS daemons and services (`launchd`, `Windows Services`, `systemd`) will be used to ensure that scheduled comments are posted reliably, even when the main application is not running.
*   **Modular Services**: The application's logic will be separated into distinct, testable services for handling tasks like CSV parsing, API communication, job state management, and logging.

## 4. Development Milestones & Phases (macOS)

The development for the macOS application is structured into the following phases. Phases 1-4 have been completed by creating a comprehensive project scaffold.

*   **Phase 1: Project Foundation & Documentation Setup (Complete)**
    *   Establish the project's directory structure, including platform-specific subdirectories and dedicated documentation folders.

*   **Phase 2: Core Logic Implementation (Complete)**
    *   Develop the core, non-UI modules, including a robust CSV parser, a placeholder Facebook API client, the `KeychainService` for secure storage, the `JobStateService`, the `CommentSchedulerService` with SwiftData, the `RateLimiter`, and the `LoggingService`.

*   **Phase 3: User Interface Development (Complete)**
    *   Build the complete user interface using SwiftUI, creating views for all primary features such as file selection, settings, the main navigation, progress display, and the dry-run preview.

*   **Phase 4: Advanced Features & Distribution (Complete)**
    *   Implement placeholder services for Gumroad license verification.
    *   Create the necessary scripts and configuration for setting up the `launchd` background agent and for building and packaging the final `.dmg` file for distribution.

*   **Phase 5: Integration and Testing (Future Work)**
    *   Connect the SwiftUI views to the backend services to create a fully functional application.
    *   Implement the complete, secure Facebook OAuth 2.0 user authentication flow.
    *   Conduct thorough unit, integration, and manual testing to ensure quality and stability.

*   **Phase 6: Windows & Linux Development (Future Work)**
    *   Commence development of the Windows and Linux applications, following a similar phased approach.

## 5. Testing, Documentation, and Distribution Plan

*   **Testing**: A multi-layered testing strategy will be employed, including unit tests for core services, integration tests for end-to-end workflows, and manual user acceptance testing.
*   **Documentation**: Both user-facing and developer-facing documentation will be maintained in the `docs/` and `macos/docs/` directories, covering usage, setup, and contribution guidelines.
*   **Distribution**: The final, signed application will be packaged into a `.dmg` file and distributed to users through Gumroad.

# Facebook Flashcard Automation - Feature Specification

**Version**: 2.0.0  
**Author**: Project & Co  
**Purpose**: Complete feature specification for building native desktop applications (macOS, Windows, Linux)

---

## 1. Application Overview

### 1.1 Core Purpose
Automate posting of flashcard content to Facebook Pages, where:
- **Questions** are posted as Facebook Page posts
- **Answers** are posted as comments on those posts
- Content is sourced from CSV files
- Posts can have colored backgrounds
- Scheduling and automation features included

### 1.2 Target Users
- Educational content creators
- Study group administrators
- Quiz page managers
- Social media managers
- Non-technical users (must be beginner-friendly)

---

## 2. Core Features

### 2.1 CSV Processing

**Input Format**:
```csv
Question,Answer
What is the capital of France?,Paris
What is 2+2?,Four
```

**Requirements**:
- Read CSV files with `Question,Answer` headers
- Support UTF-8 encoding
- Validate CSV format before processing
- Handle large files (100+ rows)
- Preview CSV contents before posting
- Cache CSV data to avoid duplicate reads

**Error Handling**:
- File not found
- Invalid encoding (non-UTF-8)
- Missing headers
- Empty files
- Malformed rows

---

### 2.2 Facebook Integration

**Authentication**:
- OAuth 2.0 flow via Facebook Login
- Store credentials securely (OS keychain/credential manager)
- Token expiration tracking
- Automatic token refresh when possible
- Support for multiple Facebook Pages

**Required Permissions**:
- `pages_show_list` - List user's pages
- `pages_read_engagement` - Read page data
- `pages_manage_posts` - Create posts and comments

**API Endpoints Used**:
- `GET /{page-id}` - Get page info
- `POST /{page-id}/feed` - Create post
- `POST /{post-id}/comments` - Create comment
- `GET /me/accounts` - List pages
- `GET /debug_token` - Validate token

**API Version**: Graph API v18.0 (or latest)

---

### 2.3 Posting Features

#### 2.3.1 Basic Posting
- Post questions to Facebook Page feed
- Post answers as first comment
- Configurable interval between posts (default: 5 seconds, min: 3 seconds)
- Progress tracking with visual feedback
- Pause/resume capability
- Cancel operation

#### 2.3.2 Colored Backgrounds
- Support Facebook's text format presets (colored backgrounds)
- Predefined color presets: Red, Blue, Green, Yellow, Purple, Orange, Pink, Black
- Color cycling mode (rotate through all colors)
- Character limit: 130 characters for colored backgrounds
- Automatic validation and skipping of too-long questions

**Color Preset IDs** (Facebook Graph API):
```json
{
  "red": "738549906179279",
  "blue": "738549906179279",
  "green": "738549906179279",
  "yellow": "738549906179279",
  "purple": "738549906179279",
  "orange": "738549906179279",
  "pink": "738549906179279",
  "black": "738549906179279"
}
```

#### 2.3.3 Comment Options
- **Immediate comments** (default): Post answer immediately after question
- **Delayed comments**: Schedule answer to be posted X hours later (1-48 hours)
- **No comments**: Post questions only, skip answers entirely

**Interactive Prompts**:
```
Post answer comments? [immediate/delayed/no] (immediate):
```

If delayed:
```
Delay (hours) (2): 
```

---

### 2.4 Scheduled Comment System

**Database**: SQLite
- Location: `~/.flashcard_automation/scheduled_comments.db`
- Schema:
  ```sql
  CREATE TABLE scheduled_comments (
      id TEXT PRIMARY KEY,
      post_id TEXT NOT NULL,
      comment_text TEXT NOT NULL,
      scheduled_for TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      posted_at TEXT,
      attempts INTEGER DEFAULT 0,
      last_error TEXT
  );
  ```

**Background Scheduler**:
- Daemon/service runs in background
- Checks every 60 seconds for due comments
- Auto-starts when user schedules comments
- Graceful shutdown handling
- PID file tracking

**Startup Recovery**:
- On app startup, check for overdue comments
- Prompt user to post overdue comments
- Offer to restart scheduler daemon if stopped
- No data loss on computer shutdown/restart

**Management Commands**:
- View scheduler status
- List scheduled comments
- View statistics (pending/posted/failed)

---

### 2.5 Job State Management

**Resume Capability**:
- Automatically save progress after each post
- Detect incomplete jobs on startup
- Prompt user to resume from where they left off
- Track: processed items, successful, failed, skipped

**Job State Storage**:
- Location: `~/.flashcard_automation/jobs/`
- Format: JSON files
- One file per job
- Includes: job ID, CSV file, timestamp, progress

**Resume Prompt**:
```
⚠️  Found incomplete job:
  Progress: 25/50 (50.0%)
  Successful: 23  Failed: 1  Skipped: 1

Resume from where you left off? [Y/n]:
```

---

### 2.6 Dry Run Mode

**Features**:
- Preview posts without actually posting
- Rich visual preview with:
  - Simulated post appearance
  - Character counts
  - Color preview (if applicable)
  - Batch statistics
  - Warnings for too-long questions
- Pagination (show first 5, then "... and X more")
- Interactive confirmation before proceeding

**Preview Display**:
```
┌─ Post Preview (1/50) ─────────────────────┐
│ 🔵 Blue Background                        │
│                                           │
│ ❓ Question:                              │
│ What is the capital of France?            │
│ (35 chars) ✓                              │
│                                           │
│ 💬 Answer (First Comment):                │
│ Paris                                     │
│ (5 chars)                                 │
└───────────────────────────────────────────┘
```

---

### 2.7 Pre-flight Validation

**Health Check Command**:
- Verify credentials exist
- Check internet connectivity
- Validate Facebook token
- Test page access
- Verify post permissions
- Display results in table format

**Checks Performed**:
1. Credential presence
2. Token expiration
3. Internet connectivity (ping facebook.com)
4. Token validity (debug_token API)
5. Page access
6. Post permissions

**Output**:
```
┌─────────────────────────┬────────┐
│ Check                   │ Status │
├─────────────────────────┼────────┐
│ Credentials             │ ✓ PASS │
│ Token Expiration        │ ✓ PASS │
│ Internet Connectivity   │ ✓ PASS │
│ Token Validation        │ ✓ PASS │
│ Page Access             │ ✓ PASS │
│ Post Permissions        │ ✓ PASS │
└─────────────────────────┴────────┘
```

---

### 2.8 Rate Limiting

**Intelligent Rate Limiter**:
- Token bucket algorithm
- Adaptive backoff on rate limits
- Automatic slowdown when limits detected
- Gradual speed increase on success
- Statistics tracking

**Configuration**:
- Bucket capacity: 10 requests
- Refill rate: 1 request per second
- Max backoff: 60 seconds
- Backoff multiplier: 2x

**User Feedback**:
```
⚠️  Rate limit detected, slowing down...
⏳ Waiting 30 seconds before retry...
```

---

### 2.9 Logging System

**Log Levels**:
- DEBUG: Detailed diagnostic info
- INFO: General informational messages
- WARNING: Warning messages
- ERROR: Error messages
- CRITICAL: Critical failures

**Log Files**:
- Location: `~/.flashcard_automation/logs/`
- Rotation: Daily, keep 7 days
- Format: `flashcard_automation_YYYYMMDD.log`
- Max size: 10MB per file

**Verbose Mode**:
- Enable with `--verbose` or `-v` flag
- Shows DEBUG level logs
- Displays API request/response details

---

### 2.10 Output Files

**Processed CSV**:
- Location: `output/flashcards_processed_YYYYMMDD_HHMMSS.csv`
- Format:
  ```csv
  Question,Answer,Status,Details
  What is Python?,A programming language,SUCCESS,
  Very long question...,Answer,SKIPPED_TOO_LONG,131/130 chars
  Question 3,Answer 3,FAILED,API error: ...
  ```

**Status Values**:
- `SUCCESS` - Posted successfully
- `SUCCESS_NO_COMMENT` - Posted without comment
- `SUCCESS_COMMENT_SCHEDULED` - Posted, comment scheduled
- `PARTIAL_SUCCESS` - Posted but comment failed
- `SKIPPED_TOO_LONG` - Question too long for colored background
- `FAILED` - Posting failed
- `DRY_RUN_SUCCESS` - Dry run simulation

---

## 3. User Interface Requirements

### 3.1 Interactive Prompts

**CSV Selection**:
```
📄 Select CSV file:
  1. geography.csv (50 items)
  2. history.csv (30 items)
  3. science.csv (40 items)

Select file [1-3]:
```

**Color Selection**:
```
🎨 Color Options
Choose background color for posts:
  1. 🔴 Red
  2. 🔵 Blue
  3. 🟢 Green
  4. ⚫ Black
  5. 🌈 Cycle through all colors
  6. ⬜ No color (plain text)

Select option [1-6] (default: 6):
```

**Comment Options**:
```
💬 Answer Comment Options
Choose how to handle answer comments:

Post answer comments? [immediate/delayed/no] (immediate):
```

### 3.2 Progress Display

**Real-time Progress**:
```
🚀 Processing: 25/50 (50%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 50%

Processing: Item 25...
✓ Item 25 - SUCCESS

┌─ Progress Stats ─────────────────────┐
│ Processed: 25/50 (50%)               │
│ Successful: 23                       │
│ Failed: 1                            │
│ Skipped: 1                           │
│ Elapsed: 2m 5s                       │
│ Remaining: ~2m 5s                    │
└──────────────────────────────────────┘
```

### 3.3 Final Summary

```
✅ Processing complete!

┌─ Final Summary ──────────────────────┐
│ Total Items: 50                      │
│ ✓ Successful: 47                     │
│ ✗ Failed: 2                          │
│ ⊘ Skipped: 1                         │
│ ⏱  Total Time: 4m 10s                │
└──────────────────────────────────────┘

📁 Output saved to: output/flashcards_processed_20251123_092614.csv

💡 Tips:
  • 2 items failed - check the .processed.csv file for error details
  • Run 'doctor' command to diagnose issues
```

---

## 4. Configuration Management

### 4.1 Settings

**Configuration File**: `config.json` or `.env`

**Settings**:
```json
{
  "fb_app_id": "your_app_id",
  "fb_app_secret": "your_app_secret",
  "fb_page_id": "your_page_id",
  "fb_page_access_token": "your_token",
  "default_interval": 5,
  "max_retries": 3,
  "retry_delay": 5,
  "log_level": "INFO"
}
```

### 4.2 Color Presets

**File**: `presets.json`

**Format**:
```json
{
  "red": "738549906179279",
  "blue": "738549906179279",
  "green": "738549906179279",
  "yellow": "738549906179279",
  "purple": "738549906179279",
  "orange": "738549906179279",
  "pink": "738549906179279",
  "black": "738549906179279"
}
```

---

## 5. Security Features

### 5.1 Credential Storage

**Preferred**: OS-native credential manager
- macOS: Keychain
- Windows: Credential Manager
- Linux: Secret Service API (libsecret)

**Fallback**: Encrypted `.env` file

**Stored Credentials**:
- Facebook App ID
- Facebook App Secret
- Facebook Page Access Token
- Facebook Page ID

### 5.2 Token Management

**Token Metadata**:
- Expiration timestamp
- Last validation time
- Scope/permissions
- Associated page ID

**Expiration Handling**:
- Track token expiration
- Warn user before expiration
- Prompt for re-authentication
- Automatic token refresh (if supported)

---

## 6. Error Handling

### 6.1 User-Friendly Error Messages

**CSV Errors**:
```
❌ CSV file not found: sources/flashcards.csv

💡 Suggestions:
  • Check if the file exists in the sources/ directory
  • Verify the filename is correct
  • Run 'ls sources/' to see available files
```

**Authentication Errors**:
```
❌ Facebook authentication failed

💡 Possible causes:
  • Token expired - run 'login' command to re-authenticate
  • Invalid credentials - check App ID and Secret
  • Missing permissions - ensure app has required permissions
```

**API Errors**:
```
❌ Failed to post to Facebook

💡 Troubleshooting:
  • Run 'doctor' command to diagnose issues
  • Check internet connection
  • Verify page permissions
  • See logs for details: ~/.flashcard_automation/logs/
```

### 6.2 Validation

**Input Validation**:
- CSV file format
- Interval range (3-60 seconds)
- Color preset names
- Comment delay (1-48 hours)
- Conflicting flags

**Pre-posting Validation**:
- Question length (≤130 chars for colored backgrounds)
- Answer not empty
- Valid UTF-8 encoding

---

## 7. Platform-Specific Considerations

### 7.1 macOS

**Installation**:
- Homebrew support recommended
- Python 3.8+ via Homebrew
- Keychain integration for credentials

**File Locations**:
- Config: `~/Library/Application Support/FlashcardAutomation/`
- Logs: `~/Library/Logs/FlashcardAutomation/`
- Database: `~/Library/Application Support/FlashcardAutomation/`

**Daemon**:
- launchd integration for scheduler
- Auto-start on login (optional)

### 7.2 Windows

**Installation**:
- Python 3.8+ from python.org
- Credential Manager integration
- Windows Installer (MSI) recommended

**File Locations**:
- Config: `%APPDATA%\FlashcardAutomation\`
- Logs: `%APPDATA%\FlashcardAutomation\logs\`
- Database: `%APPDATA%\FlashcardAutomation\`

**Daemon**:
- Windows Service or Task Scheduler
- Auto-start on login (optional)

### 7.3 Linux

**Installation**:
- Python 3.8+ via package manager
- libsecret for credential storage
- AppImage or .deb/.rpm packages

**File Locations**:
- Config: `~/.config/flashcard-automation/`
- Logs: `~/.local/share/flashcard-automation/logs/`
- Database: `~/.local/share/flashcard-automation/`

**Daemon**:
- systemd service for scheduler
- Auto-start on login (optional)

---

## 8. Commands Reference

### 8.1 Main Commands

**login**:
- Purpose: Authenticate with Facebook
- Interactive: Yes
- Requires: App ID, App Secret
- Output: Stores credentials securely

**post**:
- Purpose: Post flashcards to Facebook
- Arguments:
  - `csv_file` (optional, prompted if not provided)
  - `--dry-run` - Preview without posting
  - `--interval N` - Seconds between posts (default: 5)
  - `--color NAME` - Color preset name
  - `--cycle-colors` - Cycle through all colors
  - `--no-comments` - Don't post answer comments
  - `--comment-delay N` - Delay comments by N hours
  - `--verbose` / `-v` - Verbose logging

**doctor**:
- Purpose: Run health checks
- Arguments:
  - `--verbose` / `-v` - Show detailed diagnostics
- Output: Table of check results

**scheduler-status**:
- Purpose: Check scheduler daemon status
- Output: Running status + pending comments

**list-scheduled**:
- Purpose: List all scheduled comments
- Output: Table with IDs, post IDs, scheduled times, status

### 8.2 Setup Commands

**setup**:
- Purpose: Run interactive setup wizard
- Interactive: Yes
- Configures: App ID, App Secret, Page selection

---

## 9. Data Flow

### 9.1 Posting Flow

```
1. User selects CSV file
2. CSV is validated and parsed
3. User selects color options
4. User selects comment options
5. Pre-flight validation runs
6. For each flashcard:
   a. Validate question length
   b. Post question to Facebook
   c. Handle comment based on options:
      - Immediate: Post comment now
      - Delayed: Save to database, schedule
      - No comments: Skip
   d. Wait interval seconds
   e. Update progress
   f. Save job state
7. Generate output CSV
8. Display final summary
```

### 9.2 Scheduled Comment Flow

```
1. Comment saved to database with scheduled time
2. Scheduler daemon checks every 60 seconds
3. When comment is due:
   a. Retrieve from database
   b. Post to Facebook
   c. Mark as posted or failed
   d. Update database
4. On app startup:
   a. Check for overdue comments
   b. Prompt user to post
   c. Check if daemon is running
   d. Offer to restart daemon
```

---

## 10. Dependencies

### 10.1 Python Libraries

**Core**:
- `requests` - HTTP requests
- `python-dotenv` - Environment variables
- `pydantic` - Data validation
- `pydantic-settings` - Settings management

**UI**:
- `rich` - Rich terminal UI
- `typer` - CLI framework

**Async**:
- `httpx` - Async HTTP client
- `tenacity` - Retry logic

**Security**:
- `keyring` - Secure credential storage

**Development**:
- `pytest` - Testing
- `mypy` - Type checking

### 10.2 External APIs

**Facebook Graph API**:
- Version: v18.0 or latest
- Endpoints: feed, comments, accounts, debug_token
- Rate limits: Respect Facebook's limits

---

## 11. Testing Requirements

### 11.1 Unit Tests

**Coverage Areas**:
- CSV parsing and validation
- Facebook API client
- Rate limiter
- Scheduled comment manager
- Job state manager
- Input validators

### 11.2 Integration Tests

**Scenarios**:
- End-to-end posting flow
- Resume capability
- Scheduled comment posting
- Startup recovery
- Error handling

### 11.3 Manual Testing

**Test Cases**:
- First-time setup
- Posting with different color options
- Dry run mode
- Interrupted job resume
- Scheduled comments with computer shutdown
- Overdue comment recovery
- Invalid CSV handling
- Network failure handling

---

## 12. Performance Requirements

### 12.1 Responsiveness

- UI updates: < 100ms
- CSV preview: < 1 second for 1000 rows
- Health check: < 5 seconds
- Startup time: < 2 seconds

### 12.2 Scalability

- Support CSV files up to 10,000 rows
- Handle 100+ scheduled comments
- Maintain performance with large job history

### 12.3 Resource Usage

- Memory: < 100MB idle, < 500MB during posting
- Disk: < 50MB for application, < 100MB for logs/data
- CPU: Minimal when idle, moderate during posting

---

## 13. Accessibility

### 13.1 Beginner-Friendly

- Interactive prompts for all options
- Clear, jargon-free error messages
- Helpful suggestions for common issues
- Visual progress indicators
- Comprehensive documentation

### 13.2 Advanced Users

- Command-line flags for automation
- Scriptable commands
- Verbose logging mode
- Programmatic API access (future)

---

## 14. Future Enhancements (Optional)

### 14.1 Potential Features

- Multiple page support
- Image attachments
- Video support
- Analytics dashboard
- Bulk scheduling
- Template system
- A/B testing
- Performance analytics
- Export/import settings
- Cloud sync

### 14.2 API Considerations

- RESTful API for programmatic access
- Webhooks for events
- Plugin system
- Third-party integrations

---

## 15. Documentation Requirements

### 15.1 User Documentation

- **README.md**: Overview, quick start
- **SETUP_GUIDE.md**: Detailed setup instructions
- **USAGE.md**: Command reference
- **FAQ.md**: Common questions (40+ entries)
- **TROUBLESHOOTING.md**: Problem-solving guide
- **TROUBLESHOOTING_TREE.md**: Decision tree with mermaid diagrams

### 15.2 Developer Documentation

- **CONTRIBUTING.md**: Contribution guidelines
- **API.md**: API documentation
- **ARCHITECTURE.md**: System architecture
- Code comments and docstrings

### 15.3 Visual Documentation

- Screenshots of setup process
- GIFs of posting flow
- Video tutorials
- Mermaid diagrams for workflows

---

## 16. Quality Assurance

### 16.1 Code Quality

- Type hints throughout
- Comprehensive error handling
- Logging at appropriate levels
- Clean code principles
- DRY (Don't Repeat Yourself)

### 16.2 User Experience

- Consistent UI/UX
- Clear feedback for all actions
- Helpful error messages
- Progress indicators
- Confirmation prompts for destructive actions

---

## 17. Compliance & Legal

### 17.1 Facebook Platform Policies

- Comply with Facebook Platform Terms
- Respect rate limits
- Handle user data responsibly
- Display appropriate attributions

### 17.2 Licensing

- Open source license (if applicable)
- Third-party library licenses
- Terms of Service
- Privacy Policy

---

## 18. Support & Maintenance

### 18.1 Support Channels

- GitHub Issues
- Documentation
- FAQ
- Community forum (optional)

### 18.2 Update Strategy

- Regular updates for Facebook API changes
- Security patches
- Bug fixes
- Feature enhancements

---

## Summary

This specification provides a complete blueprint for building native desktop applications (macOS, Windows, Linux) that replicate all features of Facebook Flashcard Automation by Project & Co.

**Key Features**:
- ✅ CSV to Facebook automation
- ✅ Colored background posts
- ✅ Scheduled comments (1-48 hours)
- ✅ Resume capability
- ✅ Dry run mode
- ✅ Health checks
- ✅ Rate limiting
- ✅ Startup recovery
- ✅ Beginner-friendly UI
- ✅ Comprehensive error handling

**Total Features**: 50+ distinct features across 18 categories

**Target Platforms**: macOS, Windows, Linux  
**Technology Stack**: Python 3.8+, Facebook Graph API v18.0+  
**User Experience**: Beginner-friendly with advanced options

---

**Document Version**: 1.0  
**Last Updated**: 2025-11-23  
**Author**: Project & Co

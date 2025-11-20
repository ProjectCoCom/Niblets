# NotebookLM Autosave Chrome Extension

This extension automatically saves your work in the NotebookLM web application, providing a seamless and reliable way to prevent data loss.

## Features

- **Autosave on every keystroke:** Your work is saved in real-time as you type.
- **Session-based drafts:** Each browser tab is treated as a separate draft, allowing you to work on multiple versions of a note simultaneously.
- **Draft restoration:** When you open a note with saved drafts, you'll be prompted to restore a previous version or start a new one.
- **Local storage:** Your drafts are saved securely in your browser's local storage.
- **User-friendly feedback:** A small, non-intrusive UI element keeps you informed about the save status.

## Installation

1.  Download the extension files.
2.  Open Chrome and navigate to `chrome://extensions`.
3.  Enable "Developer mode" in the top right corner.
4.  Click "Load unpacked" and select the `notebooklm-autosave-extension` directory.
5.  The extension is now installed and active.

## How it Works

The extension injects a content script into the NotebookLM web application. This script monitors the text editor for changes and saves the content to your browser's `localStorage`.

### Session and Draft Management

-   **Notebook ID:** The extension identifies each notebook by its unique URL.
-   **Session ID:** A unique session ID is generated for each browser tab, allowing for multiple drafts of the same note.
-   **Draft Restoration:** When you open a note, the extension checks for saved drafts. If any are found, a UI will appear, allowing you to choose which draft to restore. If you start typing without restoring a draft, a new one will be created for the current session.

### Conflict Resolution

If you have the same note open in multiple tabs, each tab will save its own draft. The "latest change wins" principle applies only within a single tab's draft. When you re-open a note, you will be able to choose which draft to restore.

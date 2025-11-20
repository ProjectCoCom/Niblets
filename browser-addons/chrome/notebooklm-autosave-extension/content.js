// Content script for NotebookLM Autosave extension

// Generate a unique ID for the current session (browser tab)
const sessionId = Date.now().toString();

// Function to get the notebook ID from the URL
function getNotebookId() {
  const match = window.location.href.match(/notebook\/([a-zA-Z0-9_-]+)/);
  return match ? match[1] : null;
}

// Function to save content to local storage
function saveContent(notebookId, sessionId, content) {
  if (!notebookId) return;
  const key = `notebooklm-autosave-${notebookId}-${sessionId}`;
  const data = {
    content: content,
    timestamp: new Date().toISOString()
  };
  localStorage.setItem(key, JSON.stringify(data));
}

// Function to get all saved drafts for a notebook
function getSavedDrafts(notebookId) {
  const drafts = [];
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (key.startsWith(`notebooklm-autosave-${notebookId}-`)) {
      const data = JSON.parse(localStorage.getItem(key));
      drafts.push({ key, ...data });
    }
  }
  return drafts.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
}

// Function to create and manage the save status UI
function createSaveStatusUI() {
  const statusUI = document.createElement('div');
  statusUI.style.position = 'fixed';
  statusUI.style.bottom = '10px';
  statusUI.style.right = '10px';
  statusUI.style.backgroundColor = '#f0f0f0';
  statusUI.style.padding = '5px 10px';
  statusUI.style.borderRadius = '5px';
  statusUI.style.fontFamily = 'sans-serif';
  statusUI.style.fontSize = '12px';
  statusUI.style.zIndex = '10000';
  statusUI.innerText = 'Autosave Ready';
  document.body.appendChild(statusUI);
  return statusUI;
}

// Function to display the drafts UI
function displayDraftsUI(drafts, editor) {
  const container = document.createElement('div');
  container.style.position = 'fixed';
  container.style.top = '10px';
  container.style.right = '10px';
  container.style.backgroundColor = 'white';
  container.style.border = '1px solid #ccc';
  container.style.padding = '10px';
  container.style.zIndex = '10000';

  const title = document.createElement('h3');
  title.innerText = 'Saved Drafts';
  container.appendChild(title);

  drafts.forEach(draft => {
    const draftElement = document.createElement('div');
    draftElement.innerText = `Draft from ${new Date(draft.timestamp).toLocaleString()}`;
    draftElement.style.cursor = 'pointer';
    draftElement.onclick = () => {
      editor.innerHTML = draft.content;
      saveContent(getNotebookId(), sessionId, editor.innerHTML);
      container.remove();
    };
    container.appendChild(draftElement);
  });

  const dismissButton = document.createElement('button');
  dismissButton.innerText = 'Dismiss';
  dismissButton.onclick = () => container.remove();
  container.appendChild(dismissButton);

  document.body.appendChild(container);
}

// Function to find the editor element and attach event listeners
function initializeAutosave() {
  const notebookId = getNotebookId();
  if (!notebookId) {
    console.log("NotebookLM Autosave: Not on a notebook page.");
    return;
  }

  // This selector is more specific to the NotebookLM application structure.
  // It may need to be adjusted if the application's HTML structure changes.
  const editor = document.querySelector('.notebook-editor-container div[role="textbox"]');

  if (editor) {
    console.log("NotebookLM Autosave: Editor found, initializing.");
    const statusUI = createSaveStatusUI();
    let saveTimeout;

    const savedDrafts = getSavedDrafts(notebookId);
    if (savedDrafts.length > 0) {
      displayDraftsUI(savedDrafts, editor);
    }

    editor.addEventListener('keyup', () => {
      statusUI.innerText = 'Saving...';
      clearTimeout(saveTimeout);
      saveContent(notebookId, sessionId, editor.innerHTML);
      saveTimeout = setTimeout(() => {
        statusUI.innerText = 'Saved!';
      }, 1000);
    });

  } else {
    setTimeout(initializeAutosave, 1000);
  }
}

// Start the initialization process
initializeAutosave();

// Helper wrapper around chrome.storage.local for standardizing extension cache queries

export const getStorageItem = async <T>(key: string): Promise<T | null> => {
  if (typeof chrome === 'undefined' || !chrome.storage) {
    // Mock local storage fallback for testing/non-extension context
    const val = localStorage.getItem(key);
    return val ? (JSON.parse(val) as T) : null;
  }

  return new Promise((resolve) => {
    chrome.storage.local.get([key], (result) => {
      resolve((result[key] as T) || null);
    });
  });
};

export const setStorageItem = async <T>(key: string, value: T): Promise<void> => {
  if (typeof chrome === 'undefined' || !chrome.storage) {
    localStorage.setItem(key, JSON.stringify(value));
    return;
  }

  return new Promise((resolve) => {
    chrome.storage.local.set({ [key]: value }, () => {
      resolve();
    });
  });
};

export const removeStorageItem = async (key: string): Promise<void> => {
  if (typeof chrome === 'undefined' || !chrome.storage) {
    localStorage.removeItem(key);
    return;
  }

  return new Promise((resolve) => {
    chrome.storage.local.remove([key], () => {
      resolve();
    });
  });
};

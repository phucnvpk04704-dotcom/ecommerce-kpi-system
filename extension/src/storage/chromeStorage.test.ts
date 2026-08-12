import { describe, it, expect, beforeEach } from 'vitest';
import { getStorageItem, setStorageItem, removeStorageItem } from './chromeStorage';

describe('chromeStorage - localStorage fallback', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it('should set and get an item successfully', async () => {
    const key = 'test_key';
    const value = { data: 'hello_world' };

    await setStorageItem(key, value);
    const retrieved = await getStorageItem(key);

    expect(retrieved).toEqual(value);
  });

  it('should return null for non-existent item', async () => {
    const retrieved = await getStorageItem('non_existent');
    expect(retrieved).toBeNull();
  });

  it('should remove an item successfully', async () => {
    const key = 'test_key';
    const value = 'some_value';

    await setStorageItem(key, value);
    await removeStorageItem(key);

    const retrieved = await getStorageItem(key);
    expect(retrieved).toBeNull();
  });
});

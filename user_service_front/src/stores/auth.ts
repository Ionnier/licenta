import { writable } from 'svelte/store';

export const authApiKey = writable<String | null>(null);
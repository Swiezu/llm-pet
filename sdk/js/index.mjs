import { readFile } from 'node:fs/promises';
import { homedir } from 'node:os';
import { join } from 'node:path';

export const serverFile = join(homedir(), 'Library/Application Support/llm-pet/server.json');

export class PetError extends Error {
  constructor(message, status) {
    super(message);
    this.status = status;
  }
}

export async function request(method, path, body, file = serverFile) {
  let info;
  try {
    info = JSON.parse(await readFile(file, 'utf8'));
  } catch {
    throw new PetError('llm-pet is not running (no server.json); start the app', 503);
  }
  let response;
  try {
    response = await fetch(`http://127.0.0.1:${info.port}${path}`, {
      method,
      headers: { authorization: `Bearer ${info.token}`, 'content-type': 'application/json' },
      body: body === undefined ? undefined : JSON.stringify(body),
      signal: AbortSignal.timeout(3000),
    });
  } catch {
    throw new PetError('llm-pet is not responding; restart the app', 503);
  }
  const data = await response.json().catch(() => ({}));
  if (!response.ok) throw new PetError(data.error || `HTTP ${response.status}`, response.status);
  return data;
}

export const status = () => request('GET', '/status');
export const say = (text, { seconds, channel, animation, link } = {}) => request('POST', '/say', { text, seconds, channel, animation, link });
export const action = name => request('POST', '/action', { name });
export const actions = async () => (await request('GET', '/actions')).actions;
export const channels = async () => (await request('GET', '/channels')).channels;
export const addChannel = async (name, color) => (await request('POST', '/channels', { name, color })).channel;
export const removeChannel = channel => request('DELETE', `/channels/${encodeURIComponent(channel)}`);
export const show = () => request('POST', '/show');
export const hide = () => request('POST', '/hide');

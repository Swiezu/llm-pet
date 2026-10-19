import assert from 'node:assert/strict';
import { createServer } from 'node:http';
import { mkdtemp, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { PetError, request } from './index.mjs';

test('sends token and body, maps errors', async () => {
  const seen = [];
  const server = createServer((req, res) => {
    let body = '';
    req.on('data', chunk => (body += chunk));
    req.on('end', () => {
      seen.push({ method: req.method, url: req.url, auth: req.headers.authorization, body });
      res.writeHead(req.url === '/say' ? 200 : 409, { 'content-type': 'application/json' });
      res.end(JSON.stringify(req.url === '/say' ? { ok: true } : { error: 'pet is hidden' }));
    });
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  const file = join(await mkdtemp(join(tmpdir(), 'llm-pet-')), 'server.json');
  await writeFile(file, JSON.stringify({ port: server.address().port, token: 'abc' }));
  assert.deepEqual(await request('POST', '/say', { text: 'hej' }, file), { ok: true });
  await assert.rejects(request('POST', '/action', { name: 'hop' }, file), error => error instanceof PetError && error.status === 409);
  assert.deepEqual(seen[0], { method: 'POST', url: '/say', auth: 'Bearer abc', body: '{"text":"hej"}' });
  server.close();
});

test('reports missing app', async () => {
  await assert.rejects(request('GET', '/status', undefined, '/nonexistent/server.json'), error => error.status === 503);
});

import assert from 'node:assert/strict';
import test from 'node:test';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import { createServer } from './server.mjs';

async function connect(fake) {
  const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
  await createServer(fake).connect(serverTransport);
  const client = new Client({ name: 'test', version: '1.0.0' });
  await client.connect(clientTransport);
  return client;
}

test('lists and calls tools', async () => {
  const calls = [];
  const client = await connect({
    say: async (text, options) => (calls.push(['say', text, options]), { ok: true }),
    action: async name => (calls.push(['action', name]), { ok: true }),
    actions: async () => [{ name: 'hop' }],
    channels: async () => [{ id: 'main' }],
    addChannel: async (name, color) => (calls.push(['add', name, color]), { id: 'x' }),
    removeChannel: async key => (calls.push(['remove', key]), { ok: true }),
    status: async () => ({ enabled: true }),
  });
  const { tools } = await client.listTools();
  assert.deepEqual(tools.map(t => t.name).sort(), ['pet_action', 'pet_actions', 'pet_add_channel', 'pet_channels', 'pet_remove_channel', 'pet_say', 'pet_status']);
  await client.callTool({ name: 'pet_say', arguments: { text: 'hej', channel: 'Build', animation: 'party', seconds: 0, link: 'https://example.com' } });
  await client.callTool({ name: 'pet_action', arguments: { name: 'typing' } });
  await client.callTool({ name: 'pet_add_channel', arguments: { name: 'Build', color: '#3B4A6B' } });
  await client.callTool({ name: 'pet_remove_channel', arguments: { channel: 'Build' } });
  assert.deepEqual(calls, [['say', 'hej', { channel: 'Build', animation: 'party', seconds: 0, link: 'https://example.com' }], ['action', 'typing'], ['add', 'Build', '#3B4A6B'], ['remove', 'Build']]);
  const bad = await client.callTool({ name: 'pet_add_channel', arguments: { name: 'x', color: 'red' } });
  assert.equal(bad.isError, true);
});

test('reports pet errors', async () => {
  const client = await connect({ status: async () => { throw new Error('llm-pet is not running'); } });
  const result = await client.callTool({ name: 'pet_status', arguments: {} });
  assert.equal(result.isError, true);
  assert.match(result.content[0].text, /not running/);
});

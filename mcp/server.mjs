#!/usr/bin/env node
import { realpathSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import * as pet from '@swiezu/llm-pet-sdk';
import { z } from 'zod';

const instructions = 'llm-pet is a pixel Clawd living on the user\'s macOS desktop. pet_say shows a short speech bubble (ideally under 120 characters, max 8 lines) on a chosen channel (bubble color) and can play an animation; pet_action plays an animation alone. Take animation and channel names from pet_actions and pet_channels. Muted channels do not show messages; only the user can mute them, in the app settings. Use it when the user asks, or when it is worth getting their attention (a long task finished, a decision is needed). Do not spam: at most one message per event.';

export function createServer(client = pet) {
  const server = new McpServer({ name: 'llm-pet', version: '0.1.0' }, { instructions });
  function tool(name, description, inputSchema, annotations, run) {
    server.registerTool(name, { description, inputSchema, annotations }, async input => {
      try {
        return { content: [{ type: 'text', text: JSON.stringify(await run(input)) }] };
      } catch (error) {
        return { isError: true, content: [{ type: 'text', text: error.message }] };
      }
    });
  }
  const write = { readOnlyHint: false, destructiveHint: false, idempotentHint: false, openWorldHint: false };
  const read = { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: false };
  const animation = z.string().min(1).max(40).describe('Animation name from pet_actions, e.g. hop, party, typing');
  const channel = z.string().min(1).max(60).describe('Channel name or id from pet_channels; defaults to the main channel');
  tool('pet_say', 'Show a message in a speech bubble above the pet, optionally on a channel and with an animation.', {
    text: z.string().min(1).max(600).describe('Bubble text; anything longer than about 8 lines is truncated'),
    channel: channel.optional(),
    animation: animation.optional(),
    seconds: z.number().min(1).max(60).optional().describe('Reading time in seconds; defaults to a length-based value'),
  }, write, ({ text, ...options }) => client.say(text, options));
  tool('pet_action', 'Play a pet animation without a bubble.', { name: animation }, write, ({ name }) => client.action(name));
  tool('pet_actions', 'List available animations (name, title, duration in seconds).', {}, read, () => client.actions());
  tool('pet_channels', 'List channels (id, name, color, muted, main).', {}, read, () => client.channels());
  tool('pet_add_channel', 'Add a channel with its own bubble color.', {
    name: z.string().min(1).max(60),
    color: z.string().regex(/^#?[0-9A-Fa-f]{6}$/).optional().describe('Bubble color #RRGGBB; defaults to the next palette color'),
  }, write, ({ name, color }) => client.addChannel(name, color));
  tool('pet_remove_channel', 'Delete a channel (the main channel cannot be deleted).', { channel }, { ...write, destructiveHint: true }, ({ channel }) => client.removeChannel(channel));
  tool('pet_status', 'Check whether the pet is running, visible and what it is doing.', {}, read, () => client.status());
  return server;
}

if (process.argv[1] && realpathSync(process.argv[1]) === fileURLToPath(import.meta.url)) {
  await createServer().connect(new StdioServerTransport());
}

import Anthropic from 'npm:@anthropic-ai/sdk@1.14.0';

/** Glow AI's conversation: the model people talk to about how they feel. */
export const CHAT_MODEL = 'claude-sonnet-5-5';
/** Summaries, insights, suggestions and safety checks: short, structured and frequent. */
export const FAST_MODEL = 'claude-haiku-5-5';

export type ClaudeTurn = { role: 'user' | 'assistant'; content: string };
export type JsonSchema = Record<string, unknown>;

/** The model declined to answer. Callers decide what the person sees. */
export class ClaudeRefusal extends Error {
  constructor(public category: string | null) {
    super(`Claude declined the request${category ? ` (${category})` : ''}`);
  }
}

let client: Anthropic | undefined;
function claude(): Anthropic {
  const apiKey = Deno.env.get('ANTHROPIC_API_KEY');
  if (!apiKey) throw new Error('ANTHROPIC_API_KEY not configured');
  return (client ??= new Anthropic({ apiKey, maxRetries: 1, timeout: 45_000 }));
}

/** Reads a JSON object from a reply, allowing for a code fence or a sentence around it. */
function parseObject(text: string): Record<string, unknown> {
  const start = text.indexOf('{');
  const end = text.lastIndexOf('}');
  if (start < 0 || end <= start) throw new Error('Claude returned no JSON object');
  return JSON.parse(text.slice(start, end + 1));
}

/**
 * One request that returns a JSON object. With `schema` the API guarantees the shape; without it
 * the system prompt must describe the keys.
 *
 * Thinking counts towards `max_tokens` on these models, so the limit is roomy and `effort` keeps
 * the answers quick.
 */
export async function completeJson(options: {
  system: string;
  messages: ClaudeTurn[] | string;
  model?: string;
  schema?: JsonSchema;
  maxTokens?: number;
}): Promise<Record<string, any>> {
  const model = options.model ?? FAST_MODEL;
  const messages: ClaudeTurn[] =
    typeof options.messages === 'string'
      ? [{ role: 'user', content: options.messages }]
      : options.messages;
  const params = {
    model,
    max_tokens: options.maxTokens ?? 4000,
    system: options.system,
    messages,
    output_config: {
      effort: 'low' as const,
      ...(options.schema
        ? { format: { type: 'json_schema' as const, schema: options.schema } }
        : {}),
    },
  };
  // Sonnet can hand a declined request to another model inside the same call. Haiku cannot.
  const response =
    model === CHAT_MODEL
      ? await claude().beta.messages.create({
          ...params,
          betas: ['server-side-fallback-2026-07-01'],
          fallbacks: 'default',
        })
      : await claude().messages.create(params);

  if (response.stop_reason === 'refusal')
    throw new ClaudeRefusal(response.stop_details?.category ?? null);
  if (response.stop_reason === 'max_tokens') throw new Error('Claude ran out of output tokens');
  let text = '';
  for (const block of response.content) if (block.type === 'text') text += block.text;
  if (!text.trim()) throw new Error('Claude returned no text');
  return options.schema ? JSON.parse(text) : parseObject(text);
}

/** A yes-or-no reading of some text against a written policy. The answer is schema-checked. */
export async function classify(policy: string, text: string): Promise<Record<string, unknown>> {
  return completeJson({
    system: policy,
    messages: `<text>\n${text}\n</text>`,
    maxTokens: 2000,
    schema: {
      type: 'object',
      additionalProperties: false,
      required: ['flagged'],
      properties: { flagged: { type: 'boolean' } },
    },
  });
}

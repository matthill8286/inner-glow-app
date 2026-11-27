const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const ts = require('typescript');
const exportsObject = {};
vm.runInNewContext(
  ts.transpileModule(
    fs.readFileSync('supabase/functions/_shared/community-moderation.ts', 'utf8'),
    { compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 } },
  ).outputText,
  { exports: exportsObject, Error },
);
const { moderateCommunityText, COMMUNITY_POLICY } = exportsObject;

test('the classifier receives the policy and the unchanged content', async () => {
  for (const flagged of [false, true]) {
    const calls = [];
    const classify = async (policy, text) => {
      calls.push({ policy, text });
      return { flagged };
    };
    assert.equal(await moderateCommunityText('Hello', classify), flagged);
    assert.deepEqual(calls, [{ policy: COMMUNITY_POLICY, text: 'Hello' }]);
  }
});

test('a missing or malformed verdict never authorizes publishing', async () => {
  for (const verdict of [undefined, null, {}, { flagged: 'false' }, { flagged: 0 }, 'OK']) {
    await assert.rejects(
      moderateCommunityText('Hello', async () => verdict),
      /Moderation result missing/,
    );
  }
});

test('a classifier failure stops publishing', async () => {
  await assert.rejects(
    moderateCommunityText('Hello', async () => {
      throw new Error('429');
    }),
    /429/,
  );
});

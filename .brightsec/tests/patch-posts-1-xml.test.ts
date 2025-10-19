import { test, before, after } from 'node:test';
import { SecRunner } from '@sectester/runner';
import { AttackParamLocation, HttpMethod } from '@sectester/scan';

const timeout = 40 * 60 * 1000;
const baseUrl = process.env.BRIGHT_TARGET_URL!;

let runner!: SecRunner;

before(async () => {
  runner = new SecRunner({
    hostname: process.env.BRIGHT_HOSTNAME!,
    projectId: process.env.BRIGHT_PROJECT_ID!
  });

  await runner.init();
});

after(() => runner.clear());

test('PATCH /posts/1.xml', { signal: AbortSignal.timeout(timeout) }, async () => {
  await runner
    .createScan({
      tests: ['sqli', 'bopla', 'xxe', 'csrf', 'xss'],
      attackParamLocations: [AttackParamLocation.BODY, AttackParamLocation.HEADER],
      starMetadata: { databases: ['SQLite'] }
    })
    .setFailFast(false)
    .timeout(timeout)
    .run({
      method: HttpMethod.PATCH,
      url: `${baseUrl}/posts/1.xml`,
      body: `<?xml version="1.0" encoding="UTF-8"?>\n<post>\n  <title>Updated Title</title>\n  <content>Updated content for the post.</content>\n</post>`,
      headers: { 'Content-Type': 'application/xml', 'X-Authentication-Token': 'your_authentication_token_here' }
    });
});
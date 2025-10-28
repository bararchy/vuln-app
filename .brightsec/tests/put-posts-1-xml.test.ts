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

test('PUT /posts/1.xml', { signal: AbortSignal.timeout(timeout) }, async () => {
  await runner
    .createScan({
      tests: ['sqli', 'xxe', 'csrf', 'bopla', 'stored_xss'],
      attackParamLocations: [AttackParamLocation.BODY, AttackParamLocation.HEADER, AttackParamLocation.QUERY],
      starMetadata: { databases: ['SQLite3'] }
    })
    .setFailFast(false)
    .timeout(timeout)
    .run({
      method: HttpMethod.PUT,
      url: `${baseUrl}/posts/1.xml?meu=1`,
      headers: { 'X-Authentication-Token': 'your-authentication-token', 'Content-Type': 'application/xml' },
      body: `<?xml version="1.0" encoding="UTF-8"?>\n<post>\n  <title>Sample Title</title>\n  <content>Sample content for the post.</content>\n</post>`
    });
});
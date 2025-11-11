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
      tests: ['sqli', 'bopla', 'xxe', 'csrf'],
      attackParamLocations: [AttackParamLocation.BODY, AttackParamLocation.HEADER, AttackParamLocation.QUERY],
      starMetadata: {
        code_source: 'bararchy/vuln-app:main',
        databases: ['SQLite3']
      }
    })
    .setFailFast(false)
    .timeout(timeout)
    .run({
      method: HttpMethod.PUT,
      url: `${baseUrl}/posts/1.xml?meu=1`,
      headers: {
        'X-Authentication-Token': 'your-authentication-token',
        'Content-Type': 'application/xml'
      },
      body: `<?xml version="1.0" encoding="UTF-8"?>\n<post>\n  <content>Sample content</content>\n  <title>Sample title</title>\n</post>`
    });
});
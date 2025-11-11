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

test('POST /users', { signal: AbortSignal.timeout(timeout) }, async () => {
  await runner
    .createScan({
      tests: ['csrf', 'bopla', 'xss', 'sqli', 'secret_tokens'],
      attackParamLocations: [AttackParamLocation.BODY],
      starMetadata: {
        code_source: 'bararchy/vuln-app:main',
        databases: ['SQLite3']
      }
    })
    .setFailFast(false)
    .timeout(timeout)
    .run({
      method: HttpMethod.POST,
      url: `${baseUrl}/users`,
      body: {
        user: {
          id: 6,
          email: 'foo@bar.com',
          password: '1',
          password_digest: '1',
          admin: true,
          created_at: '2025-08-27T19:17:42.430Z',
          updated_at: '2025-08-27T19:17:42.443Z',
          token: '5f9914789c7d603144b323fc69ae1695'
        }
      },
      headers: { 'Content-Type': 'application/json' }
    });
});
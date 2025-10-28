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

test('PUT /users/123', { signal: AbortSignal.timeout(timeout) }, async () => {
  await runner
    .createScan({
      tests: ['bopla', 'csrf', 'id_enumeration', 'sqli', 'stored_xss'],
      attackParamLocations: [AttackParamLocation.BODY],
      starMetadata: { databases: ['SQLite3'] }
    })
    .setFailFast(false)
    .timeout(timeout)
    .run({
      method: HttpMethod.PUT,
      url: `${baseUrl}/users/123`,
      body: {
        user: {
          id: 123,
          email: 'user@example.com',
          password: 'securepassword',
          admin: false,
          created_at: '2023-10-01T12:00:00Z',
          updated_at: '2023-10-01T12:00:00Z',
          token: '5f9914789c7d603144b323fc69ae1695'
        }
      },
      headers: { 'Content-Type': 'application/json' }
    });
});
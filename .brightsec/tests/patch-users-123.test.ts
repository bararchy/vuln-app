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

test('PATCH /users/123', { signal: AbortSignal.timeout(timeout) }, async () => {
  await runner
    .createScan({
      tests: ['bopla', 'csrf', 'id_enumeration', 'sqli', 'xss'],
      attackParamLocations: [AttackParamLocation.BODY],
      starMetadata: { databases: ['SQLite3'] }
    })
    .setFailFast(false)
    .timeout(timeout)
    .run({
      method: HttpMethod.PATCH,
      url: `${baseUrl}/users/123`,
      body: {
        user: {
          id: 123,
          email: 'example@example.com',
          password: 'newpassword',
          admin: false
        }
      },
      headers: { 'Content-Type': 'application/json' }
    });
});
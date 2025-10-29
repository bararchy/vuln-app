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

test('POST /users.json', { signal: AbortSignal.timeout(timeout) }, async () => {
  await runner
    .createScan({
      tests: ['csrf', 'bopla', 'stored_xss', 'secret_tokens', 'sqli'],
      attackParamLocations: [AttackParamLocation.BODY],
      starMetadata: { databases: ['SQLite3'] },
      skipStaticParams: false
    })
    .setFailFast(false)
    .timeout(timeout)
    .run({
      method: HttpMethod.POST,
      url: `${baseUrl}/users.json`,
      body: {
        user: {
          id: 1,
          email: 'example@example.com',
          password: 'password123',
          password_digest: '$2a$12$KIXQ1Y1rZ1u1Z1u1Z1u1Z.1Z1u1Z1u1Z1u1Z1u1Z1u1Z1u1Z1u1Z1u',
          admin: false,
          created_at: '2023-10-01T12:00:00Z',
          updated_at: '2023-10-01T12:00:00Z',
          token: '5f9914789c7d603144b323fc69ae1695'
        }
      },
      headers: { 'Content-Type': 'application/json' },
      auth: process.env.BRIGHT_AUTH_ID
    });
});
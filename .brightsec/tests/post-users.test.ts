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
      tests: ['mass_assignment', 'xxe', 'csrf', 'xss', 'bopla'],
      attackParamLocations: [AttackParamLocation.BODY],
      starMetadata: { databases: ['SQLite3'] }
    })
    .setFailFast(false)
    .timeout(timeout)
    .run({
      method: HttpMethod.POST,
      url: `${baseUrl}/users`,
      body: `<?xml version="1.0" encoding="UTF-8"?>
<user>
  <id>6</id>
  <email>foo@bar.com</email>
  <password_digest>1</password_digest>
  <admin>true</admin>
  <created_at>2025-08-27T19:17:42.430Z</created_at>
  <updated_at>2025-08-27T19:17:42.443Z</updated_at>
  <password>1</password>
  <token>5f9914789c7d603144b323fc69ae1695</token>
</user>`,
      headers: { 'Content-Type': 'application/xml' },
      auth: process.env.BRIGHT_AUTH_ID
    });
});
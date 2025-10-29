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

test('DELETE /posts/1.xml', { signal: AbortSignal.timeout(timeout) }, async () => {
  await runner
    .createScan({
      tests: ['bopla', 'csrf', 'id_enumeration', 'sqli', 'xxe'],
      attackParamLocations: [AttackParamLocation.PATH, AttackParamLocation.HEADER],
      starMetadata: { databases: ['SQLite3'] }
    })
    .setFailFast(false)
    .timeout(timeout)
    .run({
      method: HttpMethod.DELETE,
      url: `${baseUrl}/posts/1.xml`,
      headers: { 'X-Authentication-Token': '5f9914789c7d603144b323fc69ae1695' },
      auth: process.env.BRIGHT_AUTH_ID
    });
});
import fs from 'node:fs';
import path from 'node:path';
import { execSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');

let totalTests = 0;
let passedTests = 0;
let failedTests = 0;

function assert(condition, testName) {
  totalTests++;
  if (condition) {
    passedTests++;
    console.log(`  PASS: ${testName}`);
  } else {
    failedTests++;
    console.error(`  FAIL: ${testName}`);
  }
}

console.log('--- Testing skills-alexlivre Central Hub & Registry ---');

// Test 1: Verify pagespeed-optimizer-alexlivre directory was removed
assert(!fs.existsSync(path.join(rootDir, 'pagespeed-optimizer-alexlivre')), 'pagespeed-optimizer-alexlivre directory removed from workspace');

// Test 2: Verify registry.json exists and is valid
const registryFile = path.join(rootDir, 'registry.json');
assert(fs.existsSync(registryFile), 'registry.json exists in repo root');

let registryData = null;
try {
  registryData = JSON.parse(fs.readFileSync(registryFile, 'utf8'));
  assert(true, 'registry.json is valid JSON');
} catch (err) {
  assert(false, `registry.json is valid JSON: ${err.message}`);
}

// Test 3: Validate registry schema and entries
if (registryData) {
  assert(registryData.name === 'skills-alexlivre', 'Registry name is "skills-alexlivre"');
  assert(Array.isArray(registryData.skills) && registryData.skills.length > 0, 'Registry has a non-empty skills array');

  const pageSpeedSkill = registryData.skills.find(s => s.name === 'pagespeed-optimizer-alexlivre');
  assert(!!pageSpeedSkill, 'pagespeed-optimizer-alexlivre is registered in registry.json');

  if (pageSpeedSkill) {
    assert(pageSpeedSkill.repo === 'https://github.com/alexlivre/pagespeed-optimizer-alexlivre', 'Skill repo points to https://github.com/alexlivre/pagespeed-optimizer-alexlivre');
    assert(pageSpeedSkill.installCommand && pageSpeedSkill.installCommand.includes('npx skills add'), 'Skill has valid npx skills add command');
    assert(pageSpeedSkill.status === 'active', 'Skill status is active');
  }
}

// Test 4: Validate README.md links
const readmeFile = path.join(rootDir, 'README.md');
assert(fs.existsSync(readmeFile), 'README.md exists');
const readmeContent = fs.readFileSync(readmeFile, 'utf8');

assert(readmeContent.includes('https://github.com/alexlivre/pagespeed-optimizer-alexlivre'), 'README.md links to dedicated pagespeed-optimizer-alexlivre repo');
assert(readmeContent.includes('skills-alexlivre'), 'README.md mentions skills-alexlivre hub');
assert(readmeContent.includes('npx skills add alexlivre/pagespeed-optimizer-alexlivre'), 'README.md provides direct npx skills add command');
assert(!readmeContent.includes('├── pagespeed-optimizer-alexlivre/'), 'README tree no longer lists pagespeed-optimizer-alexlivre as local directory');

// Test 5: Validate install.mjs --list execution
try {
  const output = execSync('node install.mjs --list', { cwd: rootDir, encoding: 'utf8' });
  assert(output.includes('pagespeed-optimizer-alexlivre'), 'node install.mjs --list outputs pagespeed-optimizer-alexlivre');
  assert(output.includes('https://github.com/alexlivre/pagespeed-optimizer-alexlivre'), 'node install.mjs --list outputs repository link');
} catch (err) {
  assert(false, `node install.mjs --list failed: ${err.message}`);
}

console.log('\n------------------------------------------------');
console.log(`Total: ${totalTests} | Passed: ${passedTests} | Failed: ${failedTests}`);

if (failedTests > 0) {
  process.exit(1);
} else {
  console.log('All tests passed successfully!');
  process.exit(0);
}

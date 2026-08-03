import { spawn } from 'node:child_process';
import path from 'node:path';
import process from 'node:process';

const cwd = process.cwd();
const harnessDefinitionPath = path.join(cwd, 'harness.ps1');
const harnessProject = path.join(
  cwd,
  '..',
  'Harness',
  'src',
  'PowerShellUniversal.Frameworks.Harness',
  'PowerShellUniversal.Frameworks.Harness.csproj',
);
const harnessUrl = process.env.PSU_HARNESS_URL ?? 'http://127.0.0.1:5057';
const npmCommand = process.platform === 'win32' ? 'npm.cmd' : 'npm';
const dotnetCommand = process.platform === 'win32' ? 'dotnet.exe' : 'dotnet';

function run(command, args, extraEnv = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd,
      env: {
        ...process.env,
        ...extraEnv,
      },
      shell: process.platform === 'win32',
      stdio: 'inherit',
    });

    child.on('error', reject);
    child.on('exit', (code) => {
      if (code === 0) {
        resolve();
        return;
      }

      reject(new Error(`${command} exited with code ${code ?? 'unknown'}.`));
    });
  });
}

await run(npmCommand, ['run', 'build']);
await run(
  dotnetCommand,
  ['run', '--project', harnessProject, '--urls', harnessUrl],
  {
    Harness__DefinitionPath: harnessDefinitionPath,
  },
);
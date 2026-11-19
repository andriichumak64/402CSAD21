const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const distDir = path.join(rootDir, 'dist');

try {
  fs.mkdirSync(distDir, { recursive: true });
  fs.copyFileSync(
    path.join(rootDir, 'src', 'hello.js'),
    path.join(distDir, 'hello.js')
  );
  fs.copyFileSync(
    path.join(rootDir, 'src', 'calculator.js'),
    path.join(distDir, 'calculator.js')
  );
} catch (error) {
  console.error(error);
  process.exitCode = 1;
}

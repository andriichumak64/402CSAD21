const { add } = require('./calculator');

function main() {
  add(2, 3);
  console.log('Hello, World!');
}

if (require.main === module) {
  main();
}

module.exports = { main };

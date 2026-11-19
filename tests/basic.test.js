const { add } = require('../src/calculator');

test('basicAddition', () => {
  expect(add(2, 3)).toBe(5);
});

async function shouldThrow(promise) {
  try {
    await promise;
    assert(false, "The contract did not throw.");
  } catch (err) {
    return;
  }
}

module.exports = {
  shouldThrow,
};

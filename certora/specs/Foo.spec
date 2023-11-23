methods {
  function id(uint256) external returns (uint256) envfree;
}

rule checkIdOutputIsAlwaysEqualToInput {
  uint256 input;

  assert id(input) == input;
}

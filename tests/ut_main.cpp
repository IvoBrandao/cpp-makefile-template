#include <gtest/gtest.h>

// Entry point for the Google Test framework
int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}

// A simple test case to check if Google Test is working
TEST(SimpleTest, BasicAssertions) {
  // Expect two values to be equal
  EXPECT_EQ(1, 1);

  // Expect true to be true
  EXPECT_TRUE(true);

  // Expect false to be false
  EXPECT_FALSE(false);
}

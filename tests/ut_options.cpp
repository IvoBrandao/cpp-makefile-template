#include <gtest/gtest.h>

#include "options.hpp"  

int main(int argc, char** argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}

// Test fixture for AppOptions class
class AppOptionsTest : public ::testing::Test {
 protected:
  void SetUp() override {
    // Code to set up common resources for each test case
  }

  void TearDown() override {
    // Code to clean up after each test case
  }

  // Declare any other helper methods you may need
};

// Test case to validate parsing of options with '--option value' format
TEST_F(AppOptionsTest, ParseOptionWithValue) {
  AppOptions options;

  // Add a mock option for testing
  options.add_option("--mock", "Mock option");

  // Prepare command-line arguments
  char* argv[] = {(char*)"program_name", (char*)"--mock", (char*)"value"};
  int argc = sizeof(argv) / sizeof(argv[0]);

  // Parse options
  options.parse_user_options(argc, argv);

  // Verify the parsed options
  ASSERT_TRUE(options.has_option("--mock"));
  EXPECT_EQ(options.get_option_value("--mock"), "value");
}

// Test case to validate parsing of options with '--option=value' format
TEST_F(AppOptionsTest, ParseOptionWithValueEquals) {
  AppOptions options;

  // Add a mock option for testing
  options.add_option("--mock", "Mock option");

  // Prepare command-line arguments
  char* argv[] = {(char*)"program_name", (char*)"--mock=value"};
  int argc = sizeof(argv) / sizeof(argv[0]);

  // Parse options
  options.parse_user_options(argc, argv);

  // Verify the parsed options
  ASSERT_TRUE(options.has_option("--mock"));
  EXPECT_EQ(options.get_option_value("--mock"), "value");
}

// Test case to validate parsing of options with '-o value' format
TEST_F(AppOptionsTest, ParseShortOptionWithValue) {
  AppOptions options;

  // Add a mock option for testing
  options.add_option("-o", "Short option");

  // Prepare command-line arguments
  char* argv[] = {(char*)"program_name", (char*)"-o", (char*)"value"};
  int argc = sizeof(argv) / sizeof(argv[0]);

  // Parse options
  options.parse_user_options(argc, argv);

  // Verify the parsed options
  ASSERT_TRUE(options.has_option("-o"));
  EXPECT_EQ(options.get_option_value("-o"), "value");
}

// Test case to validate parsing of options with '-o=value' format
TEST_F(AppOptionsTest, ParseShortOptionWithValueEquals) {
  AppOptions options;

  // Add a mock option for testing
  options.add_option("-o", "Short option");

  // Prepare command-line arguments
  char* argv[] = {(char*)"program_name", (char*)"-o=value"};
  int argc = sizeof(argv) / sizeof(argv[0]);

  // Parse options
  options.parse_user_options(argc, argv);

  // Verify the parsed options
  ASSERT_TRUE(options.has_option("-o"));
  EXPECT_EQ(options.get_option_value("-o"), "value");
}

// Test case to validate parsing of multiple options
TEST_F(AppOptionsTest, ParseMultipleOptions) {
  AppOptions options;

  // Add mock options for testing
  options.add_option("--mock1", "Mock option 1");
  options.add_option("--mock2", "Mock option 2");

  // Prepare command-line arguments
  char* argv[] = {(char*)"program_name", (char*)"--mock1", (char*)"value1",
                  (char*)"--mock2=value2"};
  int argc = sizeof(argv) / sizeof(argv[0]);

  // Parse options
  options.parse_user_options(argc, argv);

  // Verify the parsed options
  ASSERT_TRUE(options.has_option("--mock1"));
  EXPECT_EQ(options.get_option_value("--mock1"), "value1");
  ASSERT_TRUE(options.has_option("--mock2"));
  EXPECT_EQ(options.get_option_value("--mock2"), "value2");
}
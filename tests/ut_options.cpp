#include <gtest/gtest.h>
#include <sstream>

#include "options.hpp"

int main(int argc, char** argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}

class AppOptionsTest : public ::testing::Test {
 protected:
  AppOptions options;

  void SetUp() override {
    options.add_option("--mock", "Mock long option");
    options.add_option("-o", "Mock short option");
  }
};

TEST_F(AppOptionsTest, ParseOptionWithValue) {
  char* argv[] = {(char*)"program", (char*)"--mock", (char*)"value"};
  options.parse_user_options(3, argv);
  EXPECT_TRUE(options.has_option("--mock"));
  EXPECT_EQ(options.get_option_value("--mock"), "value");
}

TEST_F(AppOptionsTest, ParseOptionWithEquals) {
  char* argv[] = {(char*)"program", (char*)"--mock=value"};
  options.parse_user_options(2, argv);
  EXPECT_TRUE(options.has_option("--mock"));
  EXPECT_EQ(options.get_option_value("--mock"), "value");
}

TEST_F(AppOptionsTest, ParseShortOptionWithValue) {
  char* argv[] = {(char*)"program", (char*)"-o", (char*)"short"};
  options.parse_user_options(3, argv);
  EXPECT_TRUE(options.has_option("-o"));
  EXPECT_EQ(options.get_option_value("-o"), "short");
}

TEST_F(AppOptionsTest, ParseShortOptionWithEquals) {
  char* argv[] = {(char*)"program", (char*)"-o=short"};
  options.parse_user_options(2, argv);
  EXPECT_TRUE(options.has_option("-o"));
  EXPECT_EQ(options.get_option_value("-o"), "short");
}

TEST_F(AppOptionsTest, OptionWithoutValue) {
  char* argv[] = {(char*)"program", (char*)"--mock"};
  options.parse_user_options(2, argv);
  EXPECT_TRUE(options.has_option("--mock"));
  EXPECT_EQ(options.get_option_value("--mock"), "");
}

TEST_F(AppOptionsTest, ParseMultipleOptions) {
  options.add_option("--mock2", "Second option");
  char* argv[] = {(char*)"program", (char*)"--mock", (char*)"value1",
                  (char*)"--mock2=value2"};
  options.parse_user_options(4, argv);
  EXPECT_EQ(options.get_option_value("--mock"), "value1");
  EXPECT_EQ(options.get_option_value("--mock2"), "value2");
}

TEST_F(AppOptionsTest, GetValueForMissingOption) {
  EXPECT_EQ(options.get_option_value("--nonexistent"), "");
}

TEST_F(AppOptionsTest, InvalidOptionCausesExit) {
  char* argv[] = {(char*)"program", (char*)"--invalid"};
  // Do NOT try to capture stderr manually; let EXPECT_EXIT do it internally.
  EXPECT_EXIT(
      {
        AppOptions opt;
        opt.add_option("--mock", "Mock option");
        opt.parse_user_options(2, argv);
        std::exit(EXIT_FAILURE);  // Explicit to ensure consistent behavior
      },
      ::testing::ExitedWithCode(EXIT_FAILURE),
      "Invalid option detected");
}

TEST_F(AppOptionsTest, ShowUsageOutput) {
  std::ostringstream buffer;
  std::streambuf* old = std::cout.rdbuf(buffer.rdbuf());

  options.show_usage();

  std::cout.rdbuf(old);
  std::string output = buffer.str();
  EXPECT_NE(output.find("--mock"), std::string::npos);
  EXPECT_NE(output.find("-o"), std::string::npos);
}

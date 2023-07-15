#pragma once

#include <iostream>
#include <map>
#include <stdexcept>
#include <string>
#include <string_view>
#include <vector>

/// Class for handling command-line options parsing and management.
class AppOptions {
 public:
  void add_option(const std::string_view& option_flag,
                  const std::string_view& option_description);

  void show_usage() const;

  bool has_option(const std::string_view& option_flag) const;

  std::string_view get_option_value(const std::string_view& option_flag) const;

  void parse_user_options(int argc, char* argv[]);

 private:
  bool starts_with(std::string_view str, std::string_view prefix);

  void parse_options(std::vector<std::string_view>& args);

  std::pair<std::string_view, std::string_view> split_option_value(std::string_view arg);

  std::map<std::string_view, std::string_view> user_options;
  std::map<std::string_view, std::string_view> available_options;
};

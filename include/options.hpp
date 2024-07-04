

#include <iostream>
#include <map>
#include <stdexcept>
#include <string>
#include <string_view>
#include <vector>

/// Class for handling command-line options parsing and management.
class AppOptions {
 public:
  /// Adds a new option with its description.
  ///
  /// @param option_flag The flag associated with the option (e.g., "--option").
  /// @param option_description Description of what the option does.
  void add_option(const std::string_view& option_flag,
                  const std::string_view& option_description);

  /// Displays the usage information for all available options.
  void show_usage() const;

  /// Checks if a specific option flag exists.
  ///
  /// @param option_flag The flag of the option to check (e.g., "--option").
  /// @return true if the option exists, false otherwise.
  bool has_option(const std::string_view& option_flag) const;

  /// Retrieves the value associated with a given option flag.
  ///
  /// @param option_flag The flag of the option to retrieve the value for (e.g.,
  /// "--option").
  /// @return The value associated with the option flag, or an empty string_view
  /// if not found.
  std::string_view get_option_value(const std::string_view& option_flag) const;

  /// Parses user-provided command-line options.
  ///
  /// @param argc Number of command-line arguments.
  /// @param argv Array of command-line argument strings.
  void parse_user_options(int argc, char* argv[]);

 private:
  /// Checks if a string starts with a specified prefix.
  ///
  /// @param str The string to check.
  /// @param prefix The prefix to check against.
  /// @return true if the string starts with the prefix, false otherwise.
  bool starts_with(std::string_view str, std::string_view prefix);

  /// Parses the command-line options provided as arguments.
  ///
  /// @param args Vector of command-line argument strings to parse.
  void parse_options(std::vector<std::string_view>& args);

  /// Splits an option string into its flag and value parts.
  ///
  /// @param arg The option string to split (e.g., "--option=value").
  /// @return A pair containing the flag and value extracted from the option.
  /// @throw std::runtime_error if the option string is invalid.
  std::pair<std::string_view, std::string_view> split_option_value(
      std::string_view arg);

  ///< Map storing parsed options and their values.
  std::map<std::string_view, std::string_view> user_options;

  ///< Map with available options and their description
  std::map<std::string_view, std::string_view> available_options;
};

// Examples of Argument Type:
// --option        - parse_option_no_value
// --option value  - parse_option_with_value
// --option=value  - parse_option_with_value
// -o         - parse_option_no_value
// -o value   - parse_option_with_value
// -o=value   - parse_option_with_value



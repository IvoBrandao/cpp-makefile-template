#include "options.hpp"

void AppOptions::add_option(const std::string_view& option_flag,
                            const std::string_view& option_description) {
  available_options[option_flag] = option_description;
}

void AppOptions::show_usage() const {
  std::cout << "Usage:" << std::endl;
  for (const auto& [flag, description] : available_options) {
    std::cout << "\t" << flag << "\t: " << description << std::endl;
  }
  std::cout << "\n";
}

bool AppOptions::has_option(const std::string_view& option_flag) const {
  return user_options.find(option_flag) != user_options.end();
}

std::string_view AppOptions::get_option_value(
    const std::string_view& option_flag) const {
  if (has_option(option_flag)) {
    return user_options.at(option_flag);
  }
  return "";
}

void AppOptions::parse_user_options(int argc, char* argv[]) {
  std::vector<std::string_view> args(argv + 1, argv + argc);
  try {
    parse_options(args);
  } catch (const std::exception& ex) {
    std::cerr << "Error: " << ex.what() << std::endl;
  }
}

bool AppOptions::starts_with(std::string_view str, std::string_view prefix) {
  return str.substr(0, prefix.size()) == prefix;
}

void AppOptions::parse_options(std::vector<std::string_view>& args) {
  try {
    for (auto it = args.begin(); it != args.end(); ++it) {
      std::string_view flag = *it;

      // Check if the flag contains an '=' sign
      if (flag.find('=') != std::string_view::npos) {
        auto [option, value] = split_option_value(flag);
        if (available_options.find(option) != available_options.end()) {
          user_options[option] = value;
        } else {
          std::cerr << "Invalid option detected: " << flag << std::endl;
          exit(EXIT_FAILURE);
        }
      } else {
        // Check if the flag exists in available_options
        if (available_options.find(flag) != available_options.end()) {
          auto flag_value = it + 1;

          // Check if the flag has an associated value
          if (flag_value != args.end() && !starts_with(*flag_value, "-")) {
            user_options[flag] = *flag_value;
            ++it;  // Skip the next argument (value)
          } else {
            user_options[flag] = "";  // Flag without a value
          }
        } else {
          // Print debug message to see which flag is causing the issue
          std::cerr << "Invalid option detected: " << flag << std::endl;
          exit(EXIT_FAILURE);
        }
      }
    }
  } catch (const std::exception& x) {
    std::cerr << "Error: " << x.what() << '\n';
    exit(EXIT_FAILURE);
  }
}

std::pair<std::string_view, std::string_view> AppOptions::split_option_value(
    std::string_view arg) {
  auto pos = arg.find('=');
  if (pos == std::string_view::npos) {
    throw std::runtime_error("Invalid argument format: " + std::string(arg));
  }
  std::string_view option = arg.substr(0, pos);
  std::string_view value = arg.substr(pos + 1);
  return {option, value};
}
#include "options.hpp"

int main(int argc, char* argv[]) {
  AppOptions options;

  // Add options with descriptions
  options.add_option("--option", "Long option");
  options.add_option("-o", "Short option a");

  // Parse command line arguments
  options.parse_user_options(argc, argv);

  // Display usage if requested
  if (options.has_option("-help") || options.has_option("--help")) {
    options.show_usage();
    return EXIT_SUCCESS;
  }

  try {
    // Example usage of retrieving option values
    if (options.has_option("--option") || options.has_option("-o")) {
      std::string_view value = options.get_option_value("--option");
      std::cout << "Value of --option: " << value << std::endl;
    } else {
      std::cout << "Option --option not provided." << std::endl;
    }
  } catch (const std::exception& ex) {
    std::cerr << "Error: " << ex.what() << std::endl;
    return EXIT_FAILURE;
  }

  // Your application logic here using options...
  return EXIT_SUCCESS;
}

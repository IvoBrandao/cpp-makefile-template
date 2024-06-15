#include "main.h"

#include <iostream>

#include "my_module.hpp"

int main(int argc, char **argv) {
  std::cout << "Hello World!" << std::endl;
  my_module::hello();
  return 0;
}

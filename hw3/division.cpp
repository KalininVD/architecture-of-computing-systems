#include <iostream>

std::pair<int, int> Divide(int a, int b) {
  if (a < 0 && b >= 0) {
    std::pair<int, int> result = Divide(-a, b);
    return std::make_pair(-result.first, -result.second);
  }

  if (a >= 0 && b < 0) {
    std::pair<int, int> result = Divide(a, -b);
    return std::make_pair(-result.first, result.second);
  }

  if (a < 0 && b < 0) {
    std::pair<int, int> result = Divide(-a, -b);
    return std::make_pair(result.first, -result.second);
  }

  int q = 0;
  int r = a;

  while (r >= b) {
    r -= b;
    ++q;
  }

  return std::make_pair(q, r);
}

int main() {
  int a = 0;
  int b = 0;

  std::cout << "Enter dividend: ";
  std::cin >> a;

  std::cout << "Enter divisor: ";
  std::cin >> b;

  if (b == 0) {
    std::cout << "Cannot divide by zero!";
    return 0;
  }

  auto [quotient, remainder] = Divide(a, b);

  std::cout << "Quotient = " << quotient << "\n";
  std::cout << "Remainder = " << remainder << "\n";

  return 0;
}
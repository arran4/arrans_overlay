#include <numeric>
#include <vector>

int main() {
    std::vector<int> values{1, 2, 3};
    return std::accumulate(values.begin(), values.end(), 0) == 6 ? 0 : 1;
}

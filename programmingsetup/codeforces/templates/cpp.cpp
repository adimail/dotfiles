#include <bits/stdc++.h>
using namespace std;

#define fastio                                                                 \
  ios::sync_with_stdio(false);                                                 \
  cin.tie(0);

using ll = long long;
using vi = vector<int>;
using vll = vector<ll>;
using pii = pair<int, int>;

template <typename T> void read(T &x) { cin >> x; }
template <typename T> void write(T x) { cout << x << "\n"; }

int main() {
  fastio

#ifndef ONLINE_JUDGE
      freopen("input.txt", "r", stdin);
  // freopen("output.txt", "w", stdout); // Uncomment if you want to save output
#endif

  int tc = 1;
  read(tc);

  while (tc--) {
    int n;
    read(n);
    write(n);
  }

  return 0;
}

/**
 * 4×4数独をSATソルバで解くためのCNFファイルを出力する.
 * takata.yoshiaki@kochi-tech.ac.jp, 2014.7.28
 */
#include <stdio.h>

/* 行・列・数字の個数 */
#define N  4
#define SQRT_N  2  /* sqrt(N) */

/* 節の個数 */
#define N_CLAUSE  (N * N + 3 * N * N * N * (N - 1) / 2)

/* 変数 */
#define N_VAR  (N * 111)
#define VAR(i,j,k)  (((i) * 100) + ((j) * 10) + (k) + 111)

int main()
{
  int i, i2, j, j2, k, b, p, p2;

  /* ヘッダ */
  printf("p cnf %d %d\n", N_VAR, N_CLAUSE);

  /* 制約a: すべてのマスが数字をもつ */
  for (i = 0; i < N; i++) {
    for (j = 0; j < N; j++) {
      for (k = 0; k < N; k++) {
        printf("%d ", VAR(i, j, k));
      }
      printf("0\n");
    }
  }

  /* 制約c, d: 同じ行/列に同じ数字がない */
  for (i = 0; i < N; i++) {
    for (j = 0; j < N; j++) {
      for (j2 = j + 1; j2 < N; j2++) {
        for (k = 0; k < N; k++) {
          printf("-%d ", VAR(i, j,  k));
          printf("-%d ", VAR(i, j2, k));
          printf("0\n");
          printf("-%d ", VAR(j,  i, k));
          printf("-%d ", VAR(j2, i, k));
          printf("0\n");
        }
      }
    }
  }

  /* 制約e: 同じブロックに同じ数字がない */
  for (b = 0; b < N; b++) {
    for (p = 0; p < N; p++) {
      i = b / SQRT_N * SQRT_N + p / SQRT_N;
      j = b % SQRT_N * SQRT_N + p % SQRT_N;
      for (p2 = p + 1; p2 < N; p2++) {
        i2 = b / SQRT_N * SQRT_N + p2 / SQRT_N;
        j2 = b % SQRT_N * SQRT_N + p2 % SQRT_N;
        for (k = 0; k < N; k++) {
          printf("-%d ", VAR(i,  j,  k));
          printf("-%d ", VAR(i2, j2, k));
          printf("0\n");
        }
      }
    }
  }

  return 0;
}

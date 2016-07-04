% SATソルバで遊ぼう
%
% Last modified: Sun Jul  3 18:40:22 JST 2016

------------------------------------------------------------------

SAT問題
-------
入力
  ~ 変数集合 $V$ と，$V$上の和積標準形(CNF)式 $F$
  ~ (CNF = Conjunctive Normal Form)
解
  ~ $F$を真にするような$V$への代入（のうちの一つ）


### 例1 ###
* $V=\{x_1,x_2,x_3\}$上のCNF式
      $F=(x_1\lor\neg x_2\lor\neg x_3)\land(\neg x_1\lor x_2\lor\neg x_3)
       \land(x_2\lor x_3)\land(\neg x_1\lor\neg x_2)$
* 解: $(x_1,x_2,x_3)=(0,1,0)$（別解: $(0,0,1)$）

CNFの構文
--------
* CNF式　　　　　　 $F = c_1\land c_2\land\ldots\land c_n$
* 節(clause)　　　　$c_i = l_{i1}\lor l_{i2}\lor\ldots\lor l_{im_i}$
* リテラル(literal)　 $l_{ij}$ は，$x_{k_{ij}}$ または $\neg x_{k_{ij}}$

### SATソルバへの入力（DIMACS CNF形式）

~~~~~
c
c sample CNF file
c
p cnf 3 4
1 -2 -3 0
-1 2 -3 0
2 3 0
-1 -2 0
~~~~~

* 行頭が c  --- コメント
* 行頭が p  --- ヘッダ行 `p cnf `$v$ $n$
    * $v$: 変数の個数，$n$: 節の個数
* それ以降: 1行に1個の節を記述。
    * 変数は番号1〜$v$で表す。
    * $\neg$ は $-$ で表す。
    * 各行末に 0 を記述（忘れやすいので注意）。

MiniSatの実行方法と出力構文
------------------------

~~~
$ minisat ex1.cnf out.txt
$ cat out.txt
SAT
-1 2 -3 0
~~~

Q0
===

(a) 上記の例1の解を，SATソルバを使って求めなさい。
(b) SATソルバを使って別解を求める（またはそれ以上解がないことを確かめる）にはどうすればよいか。

------------------------------------------------------------------

A-WS室でMiniSatを使う準備
-----------------------

ターミナル上で下記を実行（シェルを起動するたびに必要）

    $ source ~y-takata/Public/ase-setup

### 使えるようになるコマンド ###

* `minisat` 　　　SATソルバ
* `remove_neg`　 minisatの出力から負リテラルを消すツール
* `z3`　　　　　　SMTソルバ

~~~
$ remove_neg out.txt
SAT
2 0
~~~

ちなみに`remove_neg`の中身:

~~~
#!/bin/sh
exec sed 's/-[0-9]* //g' $@
~~~

------------------------------------------------------------------

# SATソルバで解こう

Q1
===
日曜・月曜2日間のイベントにおける担当者の割り当てを考えています。
各日，午前と午後に1名ずつ担当者を割り当てます。
メンバーは，たかし，よしこ，はなこ，けんたの4名です。
ただし，以下の制約があります。

a. どの時間枠も担当者がいる
b. 各人とも高々1回担当
c. はなこは午前しか担当できない
d. たかしは月曜日の担当ができない
e. 各日とも男子・女子1名ずつ担当

これらの制約を満たす割り当てを，SATソルバを使って見つけなさい。

	   |  S  |  M  |
	---+-----+-----+
	AM |     |     |
	---+-----+-----+
	PM |     |     |
	---+-----+-----+

Answer
------
$x_{d,t,m}=1$ ⇔ 時間枠$(d,t)$を$m$が担当  
　$d\in\{S,M\}$, $t\in\{A,P\}$, $m\in\{た,よ,は,け\}$

* 制約a = $x_{d,t,た}\lor x_{d,t,よ}\lor x_{d,t,は}\lor x_{d,t,け}$
          for $\forall d,t$.
* 制約b = $\neg x_{d,t,m}\lor\neg x_{d',t',m}$ for $\forall d,d',t,t',m$
          such that $(d,t)\neq(d',t')$.
* 制約c = $\neg x_{d,P,は}$ for $\forall d$.
* 制約d = $\neg x_{M,t,た}$ for $\forall t$.
* 制約e = $x_{d,t,m}\land x_{d,t',f}$ for
          $\forall d,\exists t,t',\exists m\in\{た,け\},\exists f\in\{よ,は\}$  
　　    =      $(x_{d,A,た}\lor x_{d,A,け}\lor x_{d,P,た}\lor x_{d,P,け})$
          $\land(x_{d,A,よ}\lor x_{d,A,は}\lor x_{d,P,よ}\lor x_{d,P,は})$
          for $\forall d$. 

$S=1$, $M=2$, $A=1$, $P=2$, $た=1$, $よ=2$, $は=3$, $け=4$とし，
$x_{111}$から$x_{224}$までを使用。

* 変数の個数は224個（本来必要な変数は2×2×4=16個）。
* 節の個数は，計36個.
    * 制約a: 4個
    * 制約b: 24個
    * 制約c: 2個
    * 制約d: 2個
    * 制約e: 4個

Q2
===
上記のQ1において，イベントが日・月・火の3日間だった場合の，制約a〜eを満たす
割り当てを，SATソルバを使って見つけなさい。ただし，制約bを以下のように変更する。

b. 各人とも高々2回担当。ただし，各人とも，同日に2回担当することはない

~~~
   |  S  |  M  |  T  |
---+-----+-----+-----+
AM |     |     |     |
---+-----+-----+-----+
PM |     |     |     |
---+-----+-----+-----+
~~~

ヒント
------

Q1の制約b「高々1回担当」は，「2回担当することはない」と読み替えることができるので，
$\neg x_{d,t,m}\lor\neg x_{d',t',m}$ という式で表せた。

同様に，「高々2回担当」は「3回担当することはない」と読み替えることができるので，
$\neg x_{d,t,m}\lor\neg x_{d',t',m}\lor\neg x_{d'',t'',m}$ 
と表すことができる。
ただし，これだと節の数が多くなり，CNFファイルを手で書く場合は少し困る
（Q3のように自動生成するならほとんど問題ない）。

「同日に2回担当することはない」という条件もあるので，「3回担当することはない」は
「3日とも担当することはない」と読み替えることができる。従って
$\neg x_{S,t,m}\lor\neg x_{M,t',m}\lor\neg x_{T,t'',m}$ 
と表すことができる。
$t,t',t''$の組合せは8通りなので，手で書くとしても我慢できる範囲であろう。
「同日に2回担当することはない」は，別途，Q1の制約bと同様に記述する。

Q3
===
4×4の数独を考える。下記の数独問題の解を，SATソルバを使って見つけなさい。

	    1 2   3 4
	  +-----+-----+
	1 | 1 . | 2 . |
	2 | . . | . . |
	  +-----+-----+
	3 | . 3 | . 4 |
	4 | . . | . . |
	  +-----+-----+

Answer
------
$x_{i,j,d}=1$ ⇔ マス$(i,j)$の数字が$d$.    
　$1\le i\le4$, $1\le j\le4$, $1\le d\le4$.

制約

a. すべてのマスが数字をもつ
b. (各マスの数字は高々1つ) --- aとcから言えるので不要
c. 同じ行に同じ数字がない
d. 同じ列に同じ数字がない
e. 同じブロックに同じ数字がない
f. 予め数字の入っているマスはその数字をもつ

ブール式

* 制約a = $x_{i,j,1}\lor x_{i,j,2}\lor x_{i,j,3}\lor x_{i,j,4}$
          for $\forall i,j$.
* 制約c = $\neg x_{i,j,k}\lor\neg x_{i,j',k}$ for $\forall i,j,j',k$
          such that $j\neq j'$.
* 制約d = $\neg x_{i,j,k}\lor\neg x_{i',j,k}$ for $\forall i,i',j,k$
          such that $i\neq i'$.
* 制約e = $\neg x_{i,j,k}\lor\neg x_{i',j',k}$ for $\forall i,i',j,j',k$
          such that $(i,j)\neq(i',j')$ and $(i,j)$と$(i',j')$は同じブロック.
* 制約f = $x_{1,1,1}\land x_{1,3,2}\land x_{3,2,3}\land x_{3,4,4}$.

変数の数, 節の数

* 変数の個数は444個（本来必要な変数は64個）。
* 節の個数は，計308個。
    * 制約a: 16個
    * 制約c, d, e: 各96個 (=4×4×6)
    * 制約f: 4個

308個の節を手で入力するのは莫迦らしい。CNFファイルを出力するプログラムを作るのがよい。
演習時間節約のため，そのようなCプログラムを配付する。

* [sudoku.c](sudoku.c)
    * このプログラムは制約a〜eに対応する節 (304個) しか出力しない。
      制約fに関する節は手で入力すること。
    * プログラム中のマクロ `N` と `SQRT_N` の値を変えれば，N×N数独問題のための節集合を出力できる。


Q4
===
与えられた4×4数独問題について，解が1つしかないことを，SATソルバを使って
確認したい。1つ解を見つけた後，それ以外に解がないことを確認するにはどうすれば
よいか。

Q5
===
9×9数独問題の解をSATソルバを使って見つける場合，節の個数はいくつ必要か。

Q6
===
SATソルバを使って，下記の数独問題の解を見つけなさい。

	    1 2 3   4 5 6   7 8 9
	  +-------+-------+-------+
	1 | . . . | . 8 5 | . . . |  
	2 | . . 4 | 2 . . | 6 5 . |  
	3 | . 9 . | . . . | . . 2 |  
	  +-------+-------+-------+
	4 | 3 . . | . . . | 4 . 9 |  
	5 | . 1 . | . 7 . | . 6 . |  
	6 | 5 . 2 | . . . | . . 3 |  
	  +-------+-------+-------+
	7 | 6 . . | . . . | . 3 . |  
	8 | . 8 3 | . . 7 | 5 . . |  
	9 | . . . | 4 9 . | . . . | 
	  +-------+-------+-------+

  (ニコリ編著. ポケット数独7 上級篇, Q109, ソフトバンククリエイティブ, 2010.)

------------------------------------------------------------------

SMTソルバでも遊ぼう
=================

* SMT = SAT Modulo Theories (背景理論付きSAT)
* 整数や実数やその他の数に関する論理式に関して解を求めるツール（もちろん限界はある）。
    * $1+2=3$ とか $2<5$ とかが背景理論。
    * $x+0=x$，$x+s(y)=s(x+y)$，$x<s(x)$，$(x<y)\land(y<z)\Rightarrow(x<z)$

### 例2 ###
* 変数: $x,y: \mathrm{Int}$
* 論理式 $F=(x+2y=20)\land(x-y=2)$
* 解: $(x,y)=(8,6)$

#### SMTソルバへの入力（SMT-LIBv2形式）

~~~
(set-logic QF_LIA)  ; Quantifier-Free Linear Integer Arithmetic
(declare-fun x () Int)
(declare-fun y () Int)
(assert (= (+ x (* 2 y)) 20)) ; x + (2 * y) = 20
(assert (= (- x y) 2))        ; x - y = 2
(check-sat)
(get-value (x y))
(exit)
~~~

* Lisp風の構文（[S式](http://en.wikipedia.org/wiki/S-expression)の列）
    * 数式は前置記法で記述
* `set-logic` で，使用する背景理論を選択
    * QF_LIA (線形整数算術), QF_LRA (線形実数算術),
      QF_NIA (線形に限らない整数算術), ...など（の名前）が定義されている。
      使えるかどうかは個々のSMTソルバによる。

Q00
===
上記の例2の解を，SMTソルバを使って求めなさい。

* ここではSMTソルバとして
  [Z3](http://z3.codeplex.com/) を使用する。

    ~~~
$ z3 -smt2 ex2.smt
sat
((x 8)
 (y 6))
    ~~~

Q7
===
Q3の4×4数独問題の解を，SMTソルバを使って求めなさい。
`assert`の数は何個必要か。

Answer
------
$x_{i,j}: \mathrm{Int}$  ; マス$(i,j)$の数字

* 制約a, b: 各マスの数字は1〜4
    * `(assert (and (<= 1 x11) (<= x11 4)))`
    * `(assert (and (<= 1 x12) (<= x12 4)))`
    * ...
* 制約c: 同じ行に同じ数字がない
    * 単純に書くと
        * `(assert (not (= x11 x12)))`
        * `(assert (not (= x11 x13)))`
        * ...
    * `distinct`を使うと短く書ける("どの2つを選んでも not equal")
        * `(assert (distinct x11 x12 x13 x14))`
        * ...
* 制約d: 同じ列に同じ数字がない
* 制約e: 同じブロックに同じ数字がない
    * 制約cと同様
* 制約f: 予め数字の入っているマスはその数字をもつ
    * `(assert (= x11 1))`
    * `(assert (= x13 2))`
    * ...

Q8
===
8-Queenパズルの解（の任意の一つ）を，SMTソルバを使って求めなさい。

8-Queenパズルとは，8×8マスの盤面に8個の駒（Queen）を配置する問題である。
ただし，どの駒についても，上下左右斜めの8方向に他の駒を配置してはいけない。

cf. [Eight Queen Puzzle](http://en.wikipedia.org/wiki/Eight_queens_puzzle)

ヒント
------
各行にちょうど1個の駒を配置するのは明らかなので，
以下の変数を宣言して，問合せを組み立てるとよいだろう。

$x_i$ : Int; 第$i$行の駒を置く列 (1〜8)

* 「第$i$行の駒と第$j$行の駒が上下に重ならない」は，$x_i\ne x_j$ と表せる。
    * `distinct`を使えば `(distinct x1 x2 ... x8)` と表せる。
* 「第$i$行の駒と第$j$行の駒が斜めに重ならない（ただし$i<j$とする）」は，
  $(x_i\ne(x_j-(j-i)))\land(x_i\ne(x_j+(j-i)))$ と表せる。
    * 　$(x_1\ne(x_2-1))\land(x_1\ne(x_2+1))
       \land(x_1\ne(x_3-2))\land(x_1\ne(x_3+2))\land\ldots$  
      $\land(x_2\ne(x_3-1))\land(x_2\ne(x_3+1))
       \land(x_2\ne(x_4-2))\land(x_2\ne(x_4+2))\land\ldots$
    * うまく式変形すれば，1個の`distinct`で表すことも可能。

Q9
===
以下の覆面算の解を，SMTソルバを使って求めなさい。
ただし，各英文字は10進数の1桁を表し，異なる文字は異なる数を表す。
また，最上位桁（SとM）は0ではない。

~~~
  SEND
+ MORE
------
 MONEY
~~~

------------------------------------------------------------------

おまけ：UFLIA
==============

* UFLIA: 未定義関数, 線形整数算術, 限量子あり
* 未定義関数と限量子を使うと，Q7のための問い合わせは以下のようにも書ける。
    * [sudoku-z3.smt](sudoku-z3.smt.txt)
* 数式で書くと以下の通り。
    * $\forall i, j$. $1\le x(i,j)\le N$
    * $\forall i, j, k$.
      $(1\le j<k\le N) \Rightarrow (x(i,j)\ne x(i,k))$
    * $\forall i, j, k$.
      $(1\le j<k\le N) \Rightarrow (x(j,i)\ne x(k,i))$
    * $\forall i, j, k, l$.
      $((1,1)\le(i,j)<(k,l)\le(N,N))\land(B(i,j)=B(k,l))
       \Rightarrow (x(i,j)\ne x(k,l))$
        * ただし，2項組間の${<},{\le}$はマスの前後関係。$B$はブロック番号。
* 限量子を扱えるSMTソルバは少ない。扱えても計算時間が掛かる。
    * Z3のほかに[CVC4](http://cvc4.cs.nyu.edu/web/)があるが，
      `sudoku-z3.smt`に対する結果は unknown。
    * Z3も，N=9の場合はtimeout ($>600$s;
      OS X 10.9.4/Intel Core i7 2.8GHz/16GB RAM)。

------------------------------------------------------------------

資料
====

* [The MiniSat Page](http://minisat.se/)
* [特集「最近のSAT技術の発展」](http://bach.istc.kobe-u.ac.jp/aisat.html)
   人工知能学会誌, Vol.25, No.1, 2010.
    * 個々の記事の [CiNii](http://ci.nii.ac.jp/) エントリが掲載されている。
      KUTからは記事本文にアクセス可能。
* [SAT/SMT Solver and Applications Graduate Seminar W2013
  ](https://ece.uwaterloo.ca/~vganesh/TEACHING/W2013/SATSMT/)
* [SAT Competition 2014](http://www.satcompetition.org/2014/)
    * [SAT Competition 2009: Benchmark Submission Guidelines
      ](http://www.satcompetition.org/2009/format-benchmarks2009.html)
        * DIMACS CNF形式（SATソルバへの入力構文の事実上の標準）
* [SMT-COMP 2014](http://smtcomp.sourceforge.net/2014/)
    * [Paricipants](http://smtcomp.sourceforge.net/2014/participants.shtml)
      を見ると，どんなツールがあるか，どの背景理論に対応しているか，大ざっぱに把握できる。
* [Z3](http://z3.codeplex.com/)
  　　 さまざまな背景理論に対応している強力なツール。
* [CVC4](http://cvc4.cs.nyu.edu/web/)
  　こちらもさまざまな背景理論に対応している。
* [SMTInterpol - an Interpolating SMT Solver
  ](http://ultimate.informatik.uni-freiburg.de/smtinterpol/)
    * SMTソルバの一つ。JARファイル1個で出来ているので，いろいろな環境で使いやすい。
* [SMT-LIB](http://smt-lib.org/)
    * [The SMT-LIBv2 Language and Tools: A Tutorial
      ](http://www.grammatech.com/resource/smt/SMTLIBTutorial.pdf)
        * SMT-LIBv2形式（SMTソルバへの入力構文の事実上の標準）

------------------------------------------------------------------

This HTML file is made from
[sat-tutorial.md](sat-tutorial.md)
with [pandoc](http://johnmacfarlane.net/pandoc/).

~~~
$ pandoc -c style.css -s sat-tutorial.md -o sat-tutorial.html
~~~

This compares the performances of miso's queue implementations against a TQueue.

Running
=======

Run the following command to execute the benchmarks in Chrome:

```
google-chrome-stable --auto-open-devtools-for-tabs \
  $(nix-build --no-out-link -A haskell.packages.ghcjsHEAD.bench-queues)/bin/bench-queues.jsexe/index.html
```

Then observe the browsers console:

```
A n=1000000 w=10
  TQueue... 2.104s
  MisoQueue... 1.677s
B n=1000000 w=10
  TQueue... 1.075s
  MisoQueue... 1.092s
```

Bugs
====

Almost always benchmark `B` fails with the following error:

```
B n=1000000 w=10
 TQueue... 1.095s

uncaught exception in Haskell thread: h$ap_1_1_fast: unexpected closure type: 2
MisoQueue...
```

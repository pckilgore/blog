#!/bin/bash

  
dune exec ./app.exe &
fswatch -o util routes models public -l 2 \
  | xargs -L1 bash -c "killall app.exe || true; (dune exec ./app.exe || true) &"

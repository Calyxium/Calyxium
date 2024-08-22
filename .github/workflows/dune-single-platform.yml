name: release

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Ocaml and Packages
        run: |
          sudo apt-get update
          sudo apt-get install opam
          opam init
          opam install dune ocamllex menhir llvm ppx_deriving

      - name: Build the project
        run: dune build

      - name: Run tests
        run: dune test
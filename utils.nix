{ stdenv }:

stdenv.mkDerivation {
  name = "utils";
  src = ./utils;
}

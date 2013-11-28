{ stdenv, fetchurl, autoconf, ncurses, which, groff, gettext
, makeWrapper
, utillinux, gnused, inetutils, coreutils
}:

stdenv.mkDerivation rec {
  name = "fish-2.0.0";

  src = fetchurl {
    url = http://fishshell.com/files/2.0.0/fish-2.0.0.tar.gz;
    sha1 = "2d28553e2ff975f8e5fed6b266f7a940493b6636";
  };

  nativeBuildInputs = [ autoconf ];

  buildInputs = [ ncurses which makeWrapper ];

  preConfigure = ''
    autoconf
  '';

  postInstall = ''
    sed -i "s|which |command -v |" "$out/share/fish/functions/type.fish"
    sed -i "s|nroff |${groff}/bin/nroff |" "$out/share/fish/functions/__fish_print_help.fish"
    sed -e "s|gettext |${gettext}/bin/gettext |" \
        -e "s|which |command -v |" \
        -i "$out/share/fish/functions/_.fish"

    mkdir $out/bin-orig
    mv $out/bin/fish $out/bin-orig

    makeWrapper $out/bin-orig/fish $out/bin/fish \
      --prefix PATH : ${coreutils}/bin \
      --prefix PATH : ${utillinux}/bin \
      --prefix PATH : ${gnused}/bin \
      --prefix PATH : ${inetutils}/bin
  '';

  meta = with stdenv.lib; {
    description = "Smart and user-friendly command line shell";
    homepage = http://fishshell.com/;
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
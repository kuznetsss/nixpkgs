{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  SDL2,
  bzip2,
  cmake,
  fluidsynth,
  game-music-emu,
  gtk3,
  imagemagick,
  libGL,
  libjpeg,
  libsndfile,
  libvpx,
  libwebp,
  mpg123,
  ninja,
  openal,
  pkg-config,
  vulkan-loader,
  zlib,
  zmusic,
}:

stdenv.mkDerivation rec {
  pname = "gzdoom";
  version = "4.14.0";

  src = fetchFromGitHub {
    owner = "ZDoom";
    repo = "gzdoom";
    rev = "g${version}";
    fetchSubmodules = true;
    hash = "sha256-+gLWt1qBKl8xGK6sALnjqPuXcBexjWKbEkbRMFtLcbE=";
  };

  patches = [ ./string_format.patch ];

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    imagemagick
    makeWrapper
    ninja
    pkg-config
  ];

  buildInputs = [
    SDL2
    bzip2
    fluidsynth
    game-music-emu
    gtk3
    libGL
    libjpeg
    libsndfile
    libvpx
    libwebp
    mpg123
    openal
    vulkan-loader
    zlib
    zmusic
  ];

  postPatch = ''
    substituteInPlace tools/updaterevision/UpdateRevision.cmake \
      --replace-fail "ret_var(Tag)" "ret_var(\"${src.rev}\")" \
      --replace-fail "ret_var(Timestamp)" "ret_var(\"1970-00-00 00:00:00 +0000\")" \
      --replace-fail "ret_var(Hash)" "ret_var(\"${src.rev}\")" \
      --replace-fail "<unknown version>" "${src.rev}"
  '';

  cmakeFlags = [
    "-DDYN_GTK=OFF"
    "-DDYN_OPENAL=OFF"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "gzdoom";
      exec = "gzdoom";
      desktopName = "GZDoom";
      comment = meta.description;
      icon = "gzdoom";
      categories = [ "Game" ];
    })
  ];

  postInstall = ''
    mv $out/bin/gzdoom $out/share/games/doom/gzdoom
    makeWrapper $out/share/games/doom/gzdoom $out/bin/gzdoom \
      --set LD_LIBRARY_PATH ${lib.makeLibraryPath [ vulkan-loader ]}

    for size in 16 24 32 48 64 128; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      magick $src/src/win32/icon1.ico -background none -resize "$size"x"$size" -flatten \
       $out/share/icons/hicolor/"$size"x"$size"/apps/gzdoom.png
    done;
  '';

  meta = {
    homepage = "https://github.com/ZDoom/gzdoom";
    description = "Modder-friendly OpenGL and Vulkan source port based on the DOOM engine";
    mainProgram = "gzdoom";
    longDescription = ''
      GZDoom is a feature centric port for all DOOM engine games, based on
      ZDoom, adding an OpenGL renderer and powerful scripting capabilities.
    '';
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      azahi
      lassulus
      Gliczy
    ];
  };
}

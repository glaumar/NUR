{ stdenv
, fetchgit
, lib
, pkgs
, themeVariants ? [ ]
, alternativeIcons ? false
, boldPanelIcons ? false
, blackPanelIcons ? false
, zipAlignPath
}:

stdenv.mkDerivation rec {
  pname = "qrookie";
  version = "0.3.0";
  src = fetchgit {
    url = "https://github.com/glaumar/QRookie.git";
    rev = "c8fd5c764086210676d2107e712bcd973240f765";
    fetchSubmodules = false;
    fetchLFS = true;
    sha256 = "sha256-rhAVPPcuMKSB04do8vZ53A7XJs/2L0QPHk01L4fRhHc=";
  };

  nativeBuildInputs = with pkgs; [
    cmake
    qt6.wrapQtAppsHook
    kdePackages.extra-cmake-modules
  ];

  buildInputs = with pkgs; [
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.qcoro
    kdePackages.kirigami
    kdePackages.qtsvg
    kdePackages.qtimageformats
  ] ++ (if (system == "x86_64-linux" || system == "aarch64-linux")
  then [ kdePackages.qqc2-breeze-style ]
  else [
    (whitesur-icon-theme.overrideAttrs
      (finalAttrs: previousAttrs: {
        nativeBuildInputs = [ gtk3 fdupes ];
        installPhase = ''
          runHook preInstall

          ./install.sh --dest $out/share/icons \
            --name WhiteSur \
            --theme ${builtins.toString themeVariants} \
            ${lib.optionalString alternativeIcons "--alternative"} \
            ${lib.optionalString boldPanelIcons "--bold"} \
            ${lib.optionalString blackPanelIcons "--black"}

          fdupes --symlinks --recurse $out/share

          runHook postInstall
        '';
      }))
  ]);

  qtWrapperArgs = with pkgs;[
    ''
      --prefix PATH : ${lib.makeBinPath [ p7zip apktool xdg-utils android-tools apksigner jdk21_headless ]}  
      --prefix PATH : ${zipAlignPath}
    ''
  ];

  cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];

  meta = with pkgs.lib; {
    homepage = "https://github.com/glaumar/QRookie";
    description = ''
      Download and install Quest games from ROOKIE Public Mirror.
    '';
    licencse = licenses.gpl3;
    platforms = platforms.all;
  };
}

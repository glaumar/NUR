{ stdenv
, fetchgit
, lib
, pkgs
, zipAlignPath
}:

stdenv.mkDerivation rec {
  pname = "qrookie";
  version = "0.4.2";
  src = fetchgit {
    url = "https://github.com/glaumar/QRookie.git";
    rev = "v0.4.2";
    fetchSubmodules = false;
    fetchLFS = true;
    sha256 = "sha256-XGljZgudFNMsMDRH0PXoR4VLS3YbMk+AEPK7MpKEJ+A=";
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
  ] ++ lib.optionals stdenv.isLinux [ 
    kdePackages.qqc2-breeze-style 
  ] ++ lib.optionals stdenv.isDarwin [
    kdePackages.breeze-icons
  ];

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

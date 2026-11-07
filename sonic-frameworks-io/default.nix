{ mkSonicDerivation, pkgs, pname, src, version, Sonic-DE, ... }:

mkSonicDerivation {

  inherit pname src version;

  patches = [
    ./allow-admin-from-store.patch
  ];

  # The 6.27-era KIO worker plugins (file, http, ftp, ...) conflict with
  # nixpkgs kio 6.31: Qt's plugin scan picks this fork's dir first, so every
  # KIO 6.31 client runs a 6.27 worker in-process and the IPC desyncs
  # (FileJob::data returns pointer garbage). This blanked clipboard history
  # restores and crashed plasmashell on image entries. nixpkgs kio ships the
  # identical worker set, so removing the fork's copies loses nothing; the
  # client then resolves nixpkgs' matching plugins instead.
  postFixup = ''
    rm -rf $out/lib/qt-6/plugins/kf6/kio
    # the debug output's .build-id symlinks point into the stripped dir
    find "$debug/lib/debug/.build-id" -type l 2>/dev/null | while IFS= read -r link; do
      [ -e "$link" ] || rm -f "$link"
    done
  '';

  buildDependencies = with pkgs; [
    acl
    attr
    zlib
    libxml2
    libxslt
    krb5

    libx11
    libxcb
    libxkbcommon
  ] 
  ++ (with pkgs.kdePackages; [
    qtbase
    qtdeclarative
    qttools
    qt5compat
    qtshadertools

    solid
    kcrash
    kcmutils
    kbookmarks
    kjobwidgets
    ktextwidgets
    kservice
    kdoctools
    kdbusaddons
    kcompletion
    kwallet
    knotifications
    kded
    #kwindowsystem
    kxmlgui
    kconfig
    #kcoreaddons
    ki18n
    kwidgetsaddons
    # vendor-patch: REQUIRED finds in CMakeLists (KF6Archive via kioworkers,
    # ColorScheme/IconThemes/ItemViews behind !KIOGUI_ONLY)
    karchive
    kcolorscheme
    kiconthemes
    kitemviews
  ])
  ++ (with Sonic-DE; [
    sonic-frameworks-auth
    sonic-frameworks-cmake-modules
    sonic-frameworks-core-addons
    sonic-frameworks-windowsystem
    # vendor-patch: KF6GuiAddons REQUIRED
    sonic-frameworks-gui-addons
  ]);

  propagatedDependencies = with pkgs; [
    switcheroo-control
    kdePackages.kded
  ];

  extraNativeBuildInputs = with pkgs; [
  ];

  extraCmakeFlags = with pkgs; [
  ];

  hasPythonBindings = false;

  meta = {
    description = "Network transparent access to files and data for Sonic-DE";
    homepage = "https://github.com/Sonic-DE/sonic-frameworks-io";
    license = pkgs.lib.licenses.gpl2Plus;
    platform = pkgs.lib.platforms.linux;
  };
}
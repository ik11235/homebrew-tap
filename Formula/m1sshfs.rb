# https://hkob.hatenablog.com/entry/2020/12/04/110000
# https://github.com/libfuse/libfuse/issues/204#issuecomment-325210736

class MacFuseRequirement < Requirement
  fatal true

  satisfy(:build_env => false) {
    File.exist?("/usr/local/include/fuse/fuse.h") &&
    !File.symlink?("/usr/local/include/fuse")
  }

  def message; <<~EOS
    macFUSE is required; install it via:
      brew install --cask macfuse
    EOS
  end
end

class M1sshfs < Formula
  desc "File system client based on SSH File Transfer Protocol"
  homepage "https://osxfuse.github.io/"
  url "https://github.com/libfuse/sshfs/releases/download/sshfs_2_5/sshfs-fuse-2.5.tar.gz"
#  sha256 "70845dde2d70606aa207db5edfe878e266f9c193f1956dd10ba1b7e9a3c8d101"
  license "GPL-2.0-or-later"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on MacFuseRequirement

  env do
    ENV.append_path "PKG_CONFIG_PATH", HOMEBREW_LIBRARY/"Homebrew/os/mac/pkgconfig/fuse"

    ENV.append_path "HOMEBREW_LIBRARY_PATHS", "/usr/local/lib"
    ENV.append_path "HOMEBREW_INCLUDE_PATHS", "/usr/local/include"
  end

  def install
    system "autoreconf", "-i"
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}", "CPPFLAGS=-D_FILE_OFFSET_BITS=64 -I/usr/local/include/fuse -I/usr/local/include" 
    system "make", "install"
  end

  test do
    system "#{bin}/sshfs", "--version"
  end
end

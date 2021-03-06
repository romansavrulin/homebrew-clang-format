class ClangFormatLambda < Formula
  desc "Formatting tools for C, C++, Obj-C, Java, JavaScript, TypeScript"
  homepage "https://clang.llvm.org/docs/ClangFormat.html"
  version "9.0.1"
  
  stable do
    depends_on "git" => :build
    url "https://github.com/llvm/llvm-project.git", :tag => "llvmorg-9.0.1"
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "811e557c5b540317ff532959f3b074d6b9763abfb58186f3a1cbeb10acfb3358" => :catalina
    sha256 "beb4842dafb9092fe56ba4dc94030b581d3ae85ae914b2c2a37ae872c88dbd34" => :mojave
    sha256 "dcea54b1734a2385a7275deb7b7fe9970cf06387d9051103476a0082614849f0" => :high_sierra
  end

  head do
    depends_on "git" => :build
    url "https://github.com/llvm/llvm-project.git"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build

  uses_from_macos "libxml2"
  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  def install
    mkdir "build" do
      args = std_cmake_args
      args << "-DCMAKE_OSX_SYSROOT=/" unless MacOS::Xcode.installed?
      args << "-DLLVM_ENABLE_PROJECTS='clang;libcxx;clang-tools-extra'"
      args << "../llvm/"
      system "cmake", "-G", "Ninja", *args
      system "ninja", "clang-format"
      bin.install "bin/clang-format"
    end
    (share/"clang").install Dir["tools/clang/tools/clang-format/clang-format*"]
  end

  test do
    # NB: below C code is messily formatted on purpose.
    (testpath/"test.c").write <<~EOS
      int         main(char *args) { \n   \t printf("hello"); }
    EOS

    assert_equal "int main(char *args) { printf(\"hello\"); }\n",
        shell_output("#{bin}/clang-format -style=Google test.c")
  end
end

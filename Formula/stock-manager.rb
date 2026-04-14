class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.10.1/stock-manager-4.10.1.tar.gz"
  sha256 "56e3632d263fae608e2b6a3d5dd7e65caf818b79cdd0b2ae0a1a7cb0d4ceddd0"
  license "MIT"
  version "4.10.1"
  depends_on "node"
  # better-sqlite3 native build fallback (prebuilt binaries are usually used,
  # but if a prebuild is unavailable for the current Node ABI, node-gyp needs
  # python at install time).
  depends_on "python@3.12" => :build
  def install
    system "npm", "install", "--production=false"
    system "npm", "run", "build"
    system "npm", "prune", "--production"
    libexec.install Dir["*"]
    (bin/"stock-manager").write <<~EOS
      #!/bin/bash
      export STOCK_MANAGER_DATA="${HOME}/.stock-manager"
      mkdir -p "$STOCK_MANAGER_DATA"
      exec "#{Formula["node"].bin}/node" "#{libexec}/bin/stock-manager" "$@"
    EOS
  end
  def post_install
    (var/"stock-manager").mkpath
  end
  def caveats
    <<~EOS
      Stock Manager v4.10.1
      stock-manager
      http://localhost:3000
    EOS
  end
  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end

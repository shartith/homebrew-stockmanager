class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.11.0/stock-manager-4.11.0.tar.gz"
  sha256 "ee76970fa8e34998876e0958dc5ab2a3086f34bc6c5092470f16b1b9c028876c"
  license "MIT"
  version "4.11.0"
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
      Stock Manager v4.11.0
      stock-manager
      http://localhost:3000
    EOS
  end
  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end

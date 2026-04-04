class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.2.0/stock-manager-4.2.0.tar.gz"
  sha256 "af507419604458787b2b8201bb9b1a484b86c3fe26eff2b39250c91a9262a309"
  license "MIT"
  version "4.2.0"

  depends_on "node"

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
      Stock Manager v4.2.0 has been installed!

      Start the server:
        stock-manager

      NAS sync: stock-manager sync
      Data is stored in: ~/.stock-manager/
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end

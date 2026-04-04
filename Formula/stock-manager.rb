class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.4.0/stock-manager-4.4.0.tar.gz"
  sha256 "84ee93dcd331ab68d3d422cd5f90f9c161611f16182106fc49dbce0ce2ef5f1c"
  license "MIT"
  version "4.4.0"
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
      Stock Manager v4.4.0
      stock-manager
      http://localhost:3000
    EOS
  end
  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end

class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.19.1/stock-manager-4.19.1.tar.gz"
  sha256 "6d5c28d931da716565893a0aee90d3b86771e3450ddb55bf6163824365785ad7"
  license "MIT"
  version "4.19.1"

  depends_on "node"
  # Python is still used at build time as a fallback for better-sqlite3 native compilation.
  depends_on "python@3.12"

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
      Stock Manager v4.19.1 — 테스트 커버리지 3개 파일 85%+

      weightOptimizer 9→98.5%, backtester 59→98%, tradingRules 74→99%.
      747 tests pass (+71). v4.19.0 양방향 NAS sync 유지.

      시작:  stock-manager
      접속:  http://localhost:3000
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end

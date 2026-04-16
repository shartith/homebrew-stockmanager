class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.14.0/stock-manager-4.14.0.tar.gz"
  sha256 "9c835a963768b72bddba2b7258ed49cc54adc5088bad3c9340a4ea676b2a38ee"
  license "MIT"
  version "4.14.0"

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
      Stock Manager v4.14.0 — 시장별 TOP 50 경쟁 구도

      추천종목이 시장별 최대 50개까지 경쟁하며,
      SELL/HOLD 시그널 시 적극 감점 → 하위 종목 자동 퇴출.
      상위 10위 + 80점 이상일 때만 관심종목 승격.

      시작:  stock-manager
      접속:  http://localhost:3000
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end

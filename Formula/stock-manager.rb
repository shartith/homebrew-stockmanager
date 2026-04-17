class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.16.0/stock-manager-4.16.0.tar.gz"
  sha256 "681bccf1662c3e3519c71d835e333703160511feea8d30ef590dd23307dcfa00"
  license "MIT"
  version "4.16.0"

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
      Stock Manager v4.16.0 — Protection 시스템 + ROI Table (freqtrade 영감)

      전략 수준 circuit breaker 3종:
      - StoplossGuard (6h 내 손절 3건 → 전체 매수 차단)
      - CooldownPeriod (종목 거래 후 30분 재진입 금지)
      - LowProfitPairs (최근 5거래 평균 <-5% → 해당 종목 매수 차단)
      ROI Table: 시간 경과별 목표 수익률 감쇠로 time-tiered exit.

      시작:  stock-manager
      접속:  http://localhost:3000
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end

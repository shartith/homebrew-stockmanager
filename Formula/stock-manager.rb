class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v5.1.0/stock-manager-5.1.0.tar.gz"
  sha256 "89d9d19a183d0808b77748f918ddd274d69e9882344085719f27be06a7e6af74"
  license "MIT"
  version "5.1.0"

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
      Stock Manager v5.1.0 — 12-Rule 매매 엔진 강화

      매매 로직: 동적 종목당 한도, 09:05~09:55 매수창,
      트레일링 sticky 활성, STAGNANT_TIME, EOD 15:00/15:20/15:50.

      안전 보강: 시장 브레이크(KOSPI/VIX), 갭상승 제외, 거래량 검증,
      호가 품질 게이트, VI 차단, intraday_state DB 영구화,
      재진입 cooldown, EOD reconcile + 일일 리포트.

      슬림화: Heatmap/PortfolioHistoryChart 제거, 사이드바 슬림화.

      시작:  stock-manager
      접속:  http://localhost:3000
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end

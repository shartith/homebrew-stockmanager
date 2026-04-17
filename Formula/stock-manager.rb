class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.15.0/stock-manager-4.15.0.tar.gz"
  sha256 "64d6975fe1f5d0df972cca7fdff6240709a80c966db1c3eb617ea4970572dbb4"
  license "MIT"
  version "4.15.0"

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
      Stock Manager v4.15.0 — 장애 복원력 + 스코어링 엔진 구조 개선

      거래정지 종목 당일 재시도 차단, LLM fallback 동적 신뢰도,
      전략 프리셋 4종(스캘핑/데이트레이딩/스윙/포지션),
      watchlistCleanup 완화, TIME_DECAY 대칭 감쇠,
      baseScore 중복 시그널 디듀플리케이션.

      시작:  stock-manager
      접속:  http://localhost:3000
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end

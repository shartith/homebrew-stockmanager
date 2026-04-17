class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v4.19.0/stock-manager-4.19.0.tar.gz"
  sha256 "df3a67d79640c15ffacfb8b0ee8d78f95a672adb53070fe5e25c844ba92ec123"
  license "MIT"
  version "4.19.0"

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
      Stock Manager v4.19.0 — 양방향 NAS sync MVP + 텔레메트리

      다른 디바이스가 올린 jsonl을 내 DB로 자동 import (append-only 8종).
      opt-in: nasImportEnabled=true로 활성화.
      weightOptimizer 조기 종료 사유 system_events 기록.
      백테스트 유의성 임계값 backtestMinTradesForSave로 조정 가능.
      676 tests pass.

      시작:  stock-manager
      접속:  http://localhost:3000
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end

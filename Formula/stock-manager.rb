class StockManager < Formula
  desc "Stock portfolio management and automated trading system"
  homepage "https://github.com/shartith/StockManager"
  url "https://github.com/shartith/StockManager/releases/download/v5.2.0/stock-manager-5.2.0.tar.gz"
  sha256 "25fa7f5901b85123062098f744abeeb896753f50e97a659ef1c5127b5fec1427"
  license "MIT"
  version "5.2.0"

  depends_on "node"
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
      Stock Manager v5.2.0 — 미체결 chase + 1분 모니터 + UI 슬림화

      매매 엔진:
        - 미체결 주문 가격 갱신 (orderChase, 5분 stale)
        - EOD 15:25 강제 시장가 (동시호가 합류 → 15:30 마감 체결 보장)
        - 1분 모니터링 (5분 → 1분)

      포지션 사이징:
        - 한도 내 정상 분할 / 한도 초과 1주만 / 가용 90% 초과 차단
        - settings.autoTradeMax 의존 제거 (KIS 잔고 자동)

      슬림화:
        - NAS 동기화 전체 제거
        - 자동매매 설정 ON/OFF 토글 2개만
        - Dashboard 차트 + 수익률 컬럼 제거

      시작:  stock-manager
      접속:  http://localhost:3000
    EOS
  end

  test do
    assert_match "stock-manager", shell_output("#{bin}/stock-manager --help 2>&1", 1)
  end
end

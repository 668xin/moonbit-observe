///|
/// Span 嵌套阶段计时 + ConsoleReporter 示例
///
/// 演示 Span 父子嵌套计时和 ConsoleReporter 的 Span 树输出
fn main {
  println("=== Span 嵌套阶段计时示例 ===")
  println("")

  // 创建根 Span
  let root = @lib.Span::new("http-request")
  let root1 = root.start()

  // 子阶段 1：DNS 查询
  let dns = @lib.Span::new("dns-lookup")
  let dns1 = dns.start()
  let mut i = 0
  while i < 500 {
    i = i + 1
  }
  let dns2 = dns1.stop()

  // 子阶段 2：TCP 连接
  let tcp = @lib.Span::new("tcp-connect")
  let tcp1 = tcp.start()
  let mut j = 0
  while j < 800 {
    j = j + 1
  }
  let tcp2 = tcp1.stop()

  // 子阶段 3：TLS 握手（嵌套子 Span）
  let tls = @lib.Span::new("tls-handshake")
  let tls1 = tls.start()

  let cert_check = @lib.Span::new("cert-verify")
  let cert_check1 = cert_check.start()
  let mut k = 0
  while k < 300 {
    k = k + 1
  }
  let cert_check2 = cert_check1.stop()

  let tls2 = tls1.add_child(cert_check2)
  let tls3 = tls2.stop()

  // 组装 Span 树
  let root2 = root1.add_child(dns2)
  let root3 = root2.add_child(tcp2)
  let root4 = root3.add_child(tls3)
  let root5 = root4.stop()

  // 使用 ConsoleReporter 输出 Span 树
  let reporter = @lib.ConsoleReporter::new()
  reporter.report_span(root5)

  // 使用 JsonReporter 序列化 Span 树
  let json_reporter = @lib.JsonReporter::new()
  json_reporter.report_span(root5)
  println("JSON output:")
  println(json_reporter.output())

  println("=== 示例结束 ===")
}

defmodule AlipayParams do
  @app_id "9021000129641351"

  @spec json_params() :: map()
  def json_params() do
    %{
      "app_id" => @app_id,
      "method" => "",
      "format" => "JSON",
      "charset" => "UTF-8",
      "sign_type" => "RSA2",
      "timestamp" => Timex.local() |> Timex.format!("{YYYY}-{0M}-{D} {h24}:{0m}:{0s}"),
      "version" => "1.0"
      #      encrypt_type: "AES",
      #    biz_content: %{}
    }
  end

  def get_private_key() do
    File.read!("static/zhifubao/RSA2048-app-private_key.txt")
  end

  # 支付宝公钥
  def get_public_key do
    File.read!("static/zhifubao/ali_public_key.txt")
  end

  def refund_card_params do
    %{
      "notify_id" => "",
      "utc_timestamp" => "",
#      "msg_type" => "",
#      "msg_app_id" => "",
#      "notify_type" => "",
#      "notify_time" => "",
#      "encrypt_type" => "AES",
      "msg_method" => "alipay.trade.refund.depositback.completed",
      "app_id" => @app_id,
      # 消息类型。目前支持类型：sys：系统消息；usr，用户消息；app，应用消息
      "sign_type" => "RSA2",
      # 消息所属的应用id
      "version" => "1.1",
      "charset" => "UTF-8",
      # 支付宝交易号
      "biz_content" =>
        %{
          "trade_no" => "",
          # 商户订单号
          "out_trade_no" => "",
          # 退款请求号
          "out_request_no" => "",
          # 退款状态
          "dback_status" => "",
          # 退款金额
          "dback_amount" => "",
          # 银行受理时间
          "bank_ack_time" => "",
          # 预计银行到账时间
          "est_bank_receipt_time" => ""
        }
        |> Jason.encode!()
    }
  end
end

#defmodule Test do
#  @moduledoc false
#  @appid "wxe8d5af3ef025f9bd"
#  @mchid "1618517748"
#  @serial_no "3D7A4DE67437BF0E37E6290A9EF87CF106A448EB"
#  @base_url "https://api.mch.weixin.qq.com"
#  @native "/v3/pay/transactions/native"
#  @app "/v3/pay/transactions/app"
#  @sel_out_trade_no_url "/v3/pay/transactions/out-trade-no/"
#  @close_out_trade_no_url "/v3/pay/transactions/out-trade-no/"
#  @refund "/v3/refund/domestic/refunds"
#  @refund_select "/v3/refund/domestic/refunds/"
#  @ptzs_url "/v3/certificates"
#  @notify_url "http://cxu2qk.natappfree.cc/api/wechatPay/callback"
#  @ptzs_no "29EA946404980EAC0D2F28BD78F0CDF333F5EEA3"
#  @apiv3_secret "yICoWQ4SO88UFJ0TFn53pIfq2skp0sBp"
#  def validate_map() do
#    map = %{
#      "appid" => @appid,
#      "mchid" => @mchid,
#      "description" => "QQ公仔",
#      "out_trade_no" => "native9611",
#      "notify_url" => @notify_url,
#      "amount" => %{
#        "currency" => "CNY",
#        "total" => 1
#      }
#    }
#    total = Map.get(map, "amount")["total"]
#    IO.inspect(total)
#    description = Map.get(map, "description")
#    IO.inspect(description)
#
#    IO.inspect(is_integer(total))
#    # 校验必需的键是否存在
#    case {
#      Map.get(map, "description"),
#      Map.get(map, "out_trade_no"),
#      Map.get(map, "notify_url"),
#      Map.get(map, "amount")["total"],
#      Map.get(map, "amount")["currency"]
#    } do
#      {value1, value2, value3, value4, value5}
#      when is_binary(value1) and is_binary(value2) and is_binary(value3) and is_integer(value4) and value5 == "CNY" ->
#        true
#      _ ->
#        false
#    end
#  end
#
#
#  def test() do
#    %{"message"=>"下单响应验签失败"}|>Jason.encode!
#  end
#
#end

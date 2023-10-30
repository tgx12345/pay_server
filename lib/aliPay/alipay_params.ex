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
      "version" => "1.0",
#      encrypt_type: "AES",
      #    biz_content: %{}
    }
  end
  def get_private_key() do
    File.read!("static/zhifubao/应用私钥RSA2048-敏感数据，请妥善保管.txt")
  end
  #支付宝公钥
  def get_public_key do
    File.read!("static/zhifubao/支付宝公钥.txt")
  end
end

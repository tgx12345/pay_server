defmodule WechatPay do
  @moduledoc false
  @aad "certificate"
  @get "GET"
  @post "POST"
  @appid "wxe8d5af3ef025f9bd"
  @mchid "1618517748"
  @serial_no "3D7A4DE67437BF0E37E6290A9EF87CF106A448EB"
  @base_url "https://api.mch.weixin.qq.com"
  @native "/v3/pay/transactions/native"
  @app "/v3/pay/transactions/app"
  @sel_out_trade_no_url "/v3/pay/transactions/out-trade-no/"
  @close_out_trade_no_url "/v3/pay/transactions/out-trade-no/"
  @refund "/v3/refund/domestic/refunds"
  @refund_select "/v3/refund/domestic/refunds/"
  @ptzs_url "/v3/certificates"
  @notify_url "http://cxu2qk.natappfree.cc/api/wechatPay/callback"
  @ptzs_no "29EA946404980EAC0D2F28BD78F0CDF333F5EEA3"
  @apiv3_secret "yICoWQ4SO88UFJ0TFn53pIfq2skp0sBp"
  #统一下单
  def place_an_order(payment_methods, body_params) do
    url = if payment_methods == 0 do
      @native
    else
      @app
    end
<<<<<<< HEAD
    body = body_params
           |> Map.put("appid", @appid)
           |> Map.put("mchid", @mchid)
    sign_nonce_timestamp_map = build_sign_str("POST", url, body)
=======
    body = %{
      "appid" => @appid,
      "mchid" => @mchid,
      "description" => "QQ公仔",
      "out_trade_no" => "native9611",
      "notify_url" => @notify_url,
      "amount" => %{
        "currency" => "CNY",
        "total" => 1
      }
    }
    sign_nonce_timestamp_map = build_sign_str(@post, url, body)
>>>>>>> 50eb56214ed9ad49b97b5ae8e9fb2b6b2b3dbb6d
    headers = get_headers(sign_nonce_timestamp_map)
    {:ok, response} = HTTPoison.post(@base_url <> url, Jason.encode!(body), headers)
    result = if get_verify(response)do
      response.body
    else
      %{"message" => "下单响应验签失败"}
      |> Jason.encode!
    end
  end

  #查询订单
  def sel_out_trade_no(num) do
<<<<<<< HEAD
    num = Map.get(num, "out_trade_no")
=======
    num = Map.get(num,"order_number")
>>>>>>> 50eb56214ed9ad49b97b5ae8e9fb2b6b2b3dbb6d
    # 构造签名串
    sign_nonce_timestamp_map = build_sign_str(@get, @sel_out_trade_no_url <> num <> "?mchid=#{@mchid}")
    headers = get_headers(sign_nonce_timestamp_map)
    {:ok, response} = HTTPoison.get(@base_url <> @sel_out_trade_no_url <> num <> "?mchid=#{@mchid}", headers)
    result = if get_verify(response)do
      response.body
    else
      %{"message" => "查询订单响应验签失败"}
      |> Jason.encode!
    end
  end

  #关闭订单
  def close_out_trade_no(num) do
<<<<<<< HEAD
    num = Map.get(num, "out_trade_no")
    body = %{"mchid" => @mchid}
    # 构造签名串
    sign_nonce_timestamp_map = build_sign_str("POST", @close_out_trade_no_url <> num <> "/close", body)
=======
    num = Map.get(num,"order_number")
    body = %{"mchid"=>@mchid}
    # 构造签名串
    sign_nonce_timestamp_map = build_sign_str(@post, @close_out_trade_no_url <> num <> "/close",body)
>>>>>>> 50eb56214ed9ad49b97b5ae8e9fb2b6b2b3dbb6d
    headers = get_headers(sign_nonce_timestamp_map)
    {:ok, response} = HTTPoison.post(
      @base_url <> @close_out_trade_no_url <> num <> "/close",
      Jason.encode!(body),
      headers
    )
    result = if get_verify(response)do
      response.body
    else
      %{"message" => "关闭订单响应验签失败"}
      |> Jason.encode!
    end
  end

  #退款申请
<<<<<<< HEAD
  def refund(body_params) do
    body = body_params

    sign_nonce_timestamp_map = build_sign_str("POST", @refund, body)
=======
  def refund(num) do
    num = Map.get(num,"order_number")
    body = %{
      "out_refund_no" => num,
      "out_trade_no" => num,
      "notify_url" => @notify_url,
      "amount" => %{
        "refund" => 1,
        "total" => 1,
        "currency" => "CNY",
      }
    }
    sign_nonce_timestamp_map = build_sign_str(@post, @refund, body)
>>>>>>> 50eb56214ed9ad49b97b5ae8e9fb2b6b2b3dbb6d
    headers = get_headers(sign_nonce_timestamp_map)
    {:ok, response} = HTTPoison.post(@base_url <> @refund, Jason.encode!(body), headers)
    result = if get_verify(response)do
      response.body
    else
      %{"message" => "退款申请响应验签失败"}
      |> Jason.encode!
    end
  end

  #退款订单查询
  def refund_select(num) do
    num = Map.get(num, "out_refund_no")
    # 构造签名串
    sign_nonce_timestamp_map = build_sign_str(@get, @refund_select <> num)
    headers = get_headers(sign_nonce_timestamp_map)
    {:ok, response} = HTTPoison.get(@base_url <> @refund_select <> num, headers)
    if get_verify(response) do
      response.body
    else
      "查询退款订单响应验签失败"
    end
  end

  #获取平台证书，动态更新公钥
  def get_ptzs() do
    # 构造签名串
    sign_nonce_timestamp_map = build_sign_str(@get, @ptzs_url)
    headers = get_headers(sign_nonce_timestamp_map)
    {:ok, response} = HTTPoison.get(@base_url <> @ptzs_url, headers)
    IO.inspect(response)
    if get_verify(response) do
      #AES_256_GCM解密证书
      body = Jason.decode!(response.body)
      encrypt_certificate = body
                            |> Map.get("data")
                            |> hd()
                            |> Map.get("encrypt_certificate")

      associated_data = Map.get(encrypt_certificate, "associated_data")
      ciphertext = Map.get(encrypt_certificate, "ciphertext")
      nonce = Map.get(encrypt_certificate, "nonce")
      data = aes_256_gcm_decrypt(ciphertext, nonce, associated_data)
      File.write("static/certs/wechatpay_ptzs.pem", data)
    end
  end

  #构造签名串GET
  def build_sign_str(http_method, url) do
    timestamp = System.system_time(:second)
    nonce_str = RandomString.generate_random_string(32)
    sign_str =
      "#{http_method}\n" <>
      "#{url}\n" <>
      "#{timestamp}\n" <>
      "#{nonce_str}\n\n"
    result = %{"nonce_str" => nonce_str, "sign_str" => sign_str, "timestamp" => timestamp}
  end

  #构造签名串POST
  def build_sign_str(http_method, url, body) do
    timestamp = System.system_time(:second)
    nonce_str = RandomString.generate_random_string(32)
    request_body = Jason.encode!(body)
    sign_str =
      "#{http_method}\n" <>
      "#{url}\n" <>
      "#{timestamp}\n" <>
      "#{nonce_str}\n" <>
      "#{request_body}\n"
    result = %{"nonce_str" => nonce_str, "sign_str" => sign_str, "timestamp" => timestamp}
  end

  #获取Authorization头
  def get_authorization(nonce_str, signature, timestamp) do
    authorization = "WECHATPAY2-SHA256-RSA2048 mchid=\"#{@mchid}\",nonce_str=\"#{nonce_str}\",signature=\"#{
      signature
    }\",timestamp=\"#{timestamp}\",serial_no=\"#{@serial_no}\""
  end

  #生成签名
  def get_signature(sign_str) do
    rsa_private_key = File.read!("static/certs/apiclient_key.pem")
    {:ok, signature} = RsaEx.sign(sign_str, rsa_private_key, :sha256)
    signature = :base64.encode(signature)
  end

  #响应的验签
  def get_verify(response) do
    headers = response.headers
    timestamp = headers
                |> Enum.find(fn {key, _value} -> key == "Wechatpay-Timestamp" end)
                |> elem(1) # 提取元组的第二个元素，即值
    request_body = response.body
    nonce_str = headers
                |> Enum.find(fn {key, _value} -> key == "Wechatpay-Nonce" end)
                |> elem(1) # 提取元组的第二个元素，即值

    signature = headers
                |> Enum.find(fn {key, _value} -> key == "Wechatpay-Signature" end)
                |> elem(1) # 提取元组的第二个元素，即值
    signature = :base64.decode(signature)
    #    pub_key = File.read!("static/certs/1618517748_wxp_pub.pem")
    ptzs = File.read!("static/certs/wechatpay_29EA946404980EAC0D2F28BD78F0CDF333F5EEA3.pem")
    pub_key_seq = X509.Certificate.from_pem!(ptzs)
    pub_key = X509.Certificate.public_key(pub_key_seq)
    verify_str =
      "#{timestamp}\n" <>
      "#{nonce_str}\n" <>
      "#{request_body}\n"
    verify_result = :public_key.verify(verify_str, :sha256, signature, pub_key)
  end

  #异步请求的验签(回调验签、解密)
  def get_verify_decrypt_back(conn) do
    body_params = conn.body_params
    json_string = """
    {
      "id": "#{Map.get(body_params, "id")}",
      "create_time": "#{Map.get(body_params, "create_time")}",
      "resource_type": "#{Map.get(body_params, "resource_type")}",
      "event_type": "#{Map.get(body_params, "event_type")}",
      "summary": "#{Map.get(body_params, "summary")}",
      "resource": {
        "original_type": "#{Map.get(Map.get(body_params, "resource"), "original_type")}",
        "algorithm": "#{Map.get(Map.get(body_params, "resource"), "algorithm")}",
        "ciphertext": "#{Map.get(Map.get(body_params, "resource"), "ciphertext")}",
        "associated_data": "#{Map.get(Map.get(body_params, "resource"), "associated_data")}",
        "nonce": "#{Map.get(Map.get(body_params, "resource"), "nonce")}"
      }
    }
    """
    json_encode = Regex.replace(~r/\s+/u, json_string, "")
    req_headers = conn.req_headers
    timestamp = req_headers
                |> Enum.find(fn {key, _value} -> key == "wechatpay-timestamp" end)
                |> elem(1) # 提取元组的第二个元素，即值
    nonce_str = req_headers
                |> Enum.find(fn {key, _value} -> key == "wechatpay-nonce" end)
                |> elem(1) # 提取元组的第二个元素，即值
    signature = req_headers
                |> Enum.find(fn {key, _value} -> key == "wechatpay-signature" end)
                |> elem(1) # 提取元组的第二个元素，即值

    signature = :base64.decode(signature)
    ptzs = File.read!("static/certs/wechatpay_29EA946404980EAC0D2F28BD78F0CDF333F5EEA3.pem")
    pub_key_seq = X509.Certificate.from_pem!(ptzs)
    pub_key = X509.Certificate.public_key(pub_key_seq)
    #构造应答签名串
    verify_str =
      "#{timestamp}\n" <>
      "#{nonce_str}\n" <>
      "#{json_encode}\n"
    verify_result = :public_key.verify(verify_str, :sha256, signature, pub_key)
    result = if verify_result == true do
      ciphertext = Map.get(Map.get(body_params, "resource"), "ciphertext")
      nonce = Map.get(Map.get(body_params, "resource"), "nonce")
      associated_data = Map.get(Map.get(body_params, "resource"), "associated_data")
      aes_256_gcm_decrypt(ciphertext, nonce, associated_data)
    else
      false
    end
  end

  #aes解密
  def aes_256_gcm_decrypt(ciphertext, nonce, associated_data) do
    iv = Base.decode64!(nonce)
    ciphertext = Base.decode64!(ciphertext)
    size = byte_size(ciphertext)
    ciphertext_size = size - 16
    <<ciphertext :: binary - size(ciphertext_size), tag :: binary - size(16)>> = ciphertext
    data = :crypto.crypto_one_time_aead(:aes_256_gcm, @apiv3_secret, nonce, ciphertext, associated_data, tag, false)
    IO.inspect(data)
  end

  #构造请求headers
  def get_headers(sign_nonce_timestamp_map) do
    sign_str = Map.get(sign_nonce_timestamp_map, "sign_str")
    signature = get_signature(sign_str)
    authorization = get_authorization(
      Map.get(sign_nonce_timestamp_map, "nonce_str"),
      signature,
      Map.get(sign_nonce_timestamp_map, "timestamp")
    )
    headers = [
      {"Authorization", authorization},
      {"Accept", "application/json"},
      {"Content-Type", "application/json"}
    ]
  end
<<<<<<< HEAD

  #验证请求参数的完整性和合法性(只验证了必填的参数)
  def checkout_place_order_map(map) do
    case {
      Map.get(map, "description"),
      Map.get(map, "out_trade_no"),
      Map.get(map, "notify_url"),
      Map.get(map, "amount")["total"],
      Map.get(map, "amount")["currency"]
    } do
      {value1, value2, value3, value4, value5}
      when is_binary(value1) and is_binary(value2) and is_binary(value3) and is_integer(value4) and value5 == "CNY" ->
        true
      _ ->
        false
    end
  end

  def checkout_refund_map(map) do
    case {
      Map.get(map, "out_refund_no"),
      Map.get(map, "out_trade_no"),
      Map.get(map, "notify_url"),
      Map.get(map, "amount")["refund"],
      Map.get(map, "amount")["total"],
      Map.get(map, "amount")["currency"]
    } do
      {value1, value2, value3, value4, value5, value6}
      when is_binary(value1) and is_binary(value2) and is_binary(value3) and is_integer(value4) and is_integer(value5) and value6 == "CNY" ->
        true
      _ ->
        false
    end
  end
=======
  
  #从请求中获取订单
#  def get_order(body_params) do
#    body = %{
#      "appid" => @appid,
#      "mchid" => @mchid,
#      "description" => Map.get(body_params,"description"),
#      "out_trade_no" => Map.get(body_params,"out_trade_no"),
#      "notify_url" => @notify_url,
#      "amount" => %{
#        "currency" => "CNY",
#        "total" => Map.get(body_params,"total")
#      }
#    }
#  end
>>>>>>> 50eb56214ed9ad49b97b5ae8e9fb2b6b2b3dbb6d
end



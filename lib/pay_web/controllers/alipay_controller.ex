defmodule AlipayController do
  use PayWeb, :controller

  @notify_url "http://cxu2qk.natappfree.cc/alipay_aysc"
  @return_url "http://cxu2qk.natappfree.cc/"
  # "https://openapi.alipay.com/gateway.do"
  @app_gateway "https://openapi-sandbox.dl.alipaydev.com/gateway.do"
  # http://localhost:4000/redirectPay?subject=大乐透&out_trade_no=000111&total_amount=9.00
  def start_pay(con, params) do
    response_location = pay(params["subject"], params["out_trade_no"], params["total_amount"])
#    IO.inspect(response_location)
    [{"Location", response_location}] = response_location
    redirect(con, external: response_location)
  end

  def trade_refund(con, params2) do
    par = AlipayParams.json_params() |> Map.put("method", "alipay.trade.refund")

    params = %{
      "biz_content" =>
        %{
          # 订单号
          "out_trade_no" => params2["out_trade_no"],
          # 总金额
          "refund_amount" => params2["refund_amount"]
        }
        |> Jason.encode!()
    }

    params = Map.merge(par, params)
    response = get_response(params)
    response = response.body |> Jason.decode!()
    IO.inspect(response)
    json(con, response)
  end

  def close_alipay(con, params2) do
    par = AlipayParams.json_params() |> Map.put("method", "alipay.trade.close")

    params = %{
      #    notify_url: @notify_url,
      "biz_content" =>
        %{
          # 订单号
          "out_trade_no" => params2["out_trade_no"]
        }
        |> Jason.encode!()
    }

    params = Map.merge(par, params)
    response = get_response(params)
    response = response.body |> Jason.decode!()
    IO.inspect(response)
    json(con, response)
  end

  def pay(subject, out_trade_no, total_amount) do
    params = AlipayParams.json_params() |> Map.put("method", "alipay.trade.page.pay")

    params2 = %{
      "return_url" => @return_url,
      "notify_url" =>  @notify_url,
      "biz_content" =>
        %{
          # 支付名称
          "subject" => subject,
          # 扫码支付方式
          "qr_pay_mode" => "2",
          # 订单号
          "out_trade_no" => out_trade_no,
          # 总金额
          "total_amount" => total_amount,
          # 固定配置
          "product_code" => "FAST_INSTANT_TRADE_PAY"
        }
        |> Jason.encode!()
    }

    params = Map.merge(params, params2)
    response = get_response(params)
    IO.inspect(response)
    response_location = response.headers |> Enum.filter(fn {key, value} -> key == "Location" end)
  end

  def select_info(con, params2) do
    par = AlipayParams.json_params() |> Map.put("method", "alipay.trade.query")

    params = %{
      "biz_content" =>
        %{
          # 订单号
          "out_trade_no" => params2["out_trade_no"],
          # 查询选项
          "query_options" => params2["query_options"]
        }
        |> Jason.encode!()
    }

    params = Map.merge(par, params)
    response = get_response(params)
    body = response.body |> Jason.decode!()
    IO.inspect(body)
  end

  def url_encode_map_value(map) do
    Enum.reduce(map, %{}, fn {key, value}, acc ->
      Map.put(acc, key, URI.encode_www_form(value))
    end)
  end

  defp sign_params(params, private_key) do
    pem_string = """
    -----BEGIN PRIVATE KEY-----
    #{private_key}
    -----END PRIVATE KEY-----
    """

    aes_key = "E1W8RFTZgfHO/d3sdjg1Ow=="

    sorted_params = map2sign_str(params)

    IO.puts(sorted_params)
    {:ok, signature} = RsaEx.sign(sorted_params, pem_string)
    signature = Base.encode64(signature)
    newMap = Map.put_new(params, "sign", signature)
    #  IO.inspect(newMap)
    newMap
  end

  def alipay_async_notice(con, params) do
    #    去除sign  sign_type  验签
    sing = params["sign"] |> Base.decode64!()
    data = params |> Map.delete("sign") |> Map.delete("sign_type")
    public_key = AlipayParams.get_public_key()

    pem_string = """
    -----BEGIN PUBLIC KEY-----
    #{public_key}
    -----END PUBLIC KEY-----
    """

    sorted_params = map2sign_str(data)

    verify_result = RsaEx.verify(sorted_params, sing, pem_string)
    IO.puts("验签结果：")
    IO.inspect(verify_result)
    json(con, params)
  end

  #  http://localhost:4000/alipay_app?subject=大乐透&out_trade_no=70501111111S001111119&total_amount=9.00
  def alipay_app(con, params2) do
    par = AlipayParams.json_params() |> Map.put("method", "alipay.trade.app.pay")

    params = %{
      #      notify_url: @notify_url,
      "biz_content" =>
        %{
          # 订单号
          "out_trade_no" => params2["out_trade_no"],
          # 总金额
          "total_amount" => params2["total_amount"],
          # 支付名称
          "subject" => params2["subject"]
        }
        |> Jason.encode!()
    }

    params = Map.merge(par, params)
    response = get_response(params)
    IO.inspect(response)
    [{"Location", response_location}] =
      response.headers |> Enum.filter(fn {key, value} -> key == "Location" end)
    redirect(con, external: response_location)
  end

  #  http://localhost:4000/redirectPay?subject=大乐透&out_trade_no=9091991&total_amount=9.00
  def alipay_refund_query(con, params2) do
    par = AlipayParams.json_params() |> Map.put("method", "alipay.trade.fastpay.refund.query")
    params = %{
      "biz_content" =>
        %{
          # 订单号
          "out_trade_no" => params2["out_trade_no"],
          # 退款请求号
          "out_request_no" => params2["out_request_no"]
          #                      "query_options" => params2["query_options"],  #查询选项
        }
        |> Jason.encode!()
    }
    params = Map.merge(par, params)
    response = get_response(params)
    IO.inspect(response)
    json(con, Jason.decode!(response.body))
  end



  def verify_sign(con, params) do
    sing = params["sign"] |> Base.decode64!()
    data = params |> Map.delete("sign") |> Map.delete("sign_type")
    public_key = AlipayParams.get_public_key()
    pem_string = """
    -----BEGIN PUBLIC KEY-----
    #{public_key}
    -----END PUBLIC KEY-----
    """
    sorted_params = map2sign_str(data)
    f = RsaEx.verify(sorted_params, sing, pem_string)
  end

  #  http://localhost:4000/redirectPay?subject=大乐透&out_trade_no=1021012023222222&total_amount=9.00
  defp get_response(sign_params) do

    #    aes_key="E1W8RFTZgfHO/d3sdjg1Ow==" |> Base.decode64!()
    #    # 此处进行加密Aes
    #    biz_content= Map.get(sign_params,"biz_content")
    #    IO.inspect(biz_content)
    #    biz_content=  Codepagex.from_string!(biz_content, :ascii)
    #    iv=<<0::128>>
    #    iv= :crypto.strong_rand_bytes(16)
    #    biz_content = :crypto.crypto_one_time(:aes_128_cbc, aes_key,iv, biz_content, true)
    #    biz_content= Base.encode64(biz_content)
    #    sign_params=Map.put(sign_params,"biz_content",biz_content)

    private_key =AlipayParams.get_private_key()

    signed_params = sign_params(sign_params, private_key)
    signed_params =url_encode_map_value(signed_params) |>map2sign_str
    url = "#{@app_gateway}?#{signed_params}"
    IO.puts(url)
    response = HTTPoison.get!(url, [{"Content-type", "application/json"}])
  end

  def map2sign_str(map)do
    map
  |> Map.to_list()
  |> Enum.sort(&(elem(&1, 0) <= elem(&2, 0)))
  |> Enum.map(&"#{elem(&1, 0)}=#{elem(&1, 1)}")
  |> Enum.join("&")
  end

end

defmodule AlipayController do
  use PayWeb, :controller

  @notify_url "http://slbzhy.cn:9102/alipay/async_url"
  @return_url "http://slbzhy.cn:9102/"
  # "https://openapi.alipay.com/gateway.do"
  @app_gateway "https://openapi-sandbox.dl.alipaydev.com/gateway.do"

  # D:\java\工作文件夹\新建文件夹\zip\neutrino-proxy-client-jar
  def start_pay(con, params) do
    json_params = AlipayParams.json_params() |> Map.put("method", "alipay.trade.page.pay")

    is_check =
      check_map_keys(params["biz_content"], [
        "subject",
        "out_trade_no",
        "total_amount",
        "product_code"
      ])
    is_legitimate = Enum.all?(params["biz_content"],fn {_,v} -> is_binary(v)&&contains_special_characters?(v)  end)
    result_map =
      if is_check && is_legitimate  do
        params2 = %{
          "return_url" => @return_url,
          "notify_url" => @notify_url,
          "biz_content" =>
            params["biz_content"]
            |> Jason.encode!()
        }
        params = Map.merge(json_params, params2)
        response = get_response(params)
        if response.status_code == 302 do
          [{"Location", response_location}] =
            response.headers |> Enum.filter(fn {key, _} -> key == "Location" end)
          %{"url" => response_location}
        else
          %{"msg_error" => "参数错误"}
        end
      else
          if !is_legitimate do
            %{"msg_error" => "参数不合法"}
            else
            %{"msg_error" => "缺少参数"}
            end
      end

    json(con, result_map)
  end

  def trade_refund(con, params2) do
    par = AlipayParams.json_params() |> Map.put("method", "alipay.trade.refund")

    is_check =
      check_map_keys(params2["biz_content"], [
        "out_trade_no",
        #        "trade_no",  二选一
        "refund_amount"
      ])
    is_legitimate = Enum.all?(params2["biz_content"],fn {_,v} -> is_binary(v)&&contains_special_characters?(v)  end)
    response =
      if is_check  && is_legitimate do
        params = %{
          "biz_content" =>
            params2["biz_content"]
            |> Jason.encode!()
        }

        params = Map.merge(par, params)
        response = get_response(params)
        response = response.body |> Jason.decode!()
        response
      else
          if !is_legitimate do
            %{"msg_error" => "参数不合法"}
            else
            %{"msg_error" => "缺少参数"}
            end

      end

    json(con, response)
  end

  def close_alipay(con, params2) do
    par = AlipayParams.json_params() |> Map.put("method", "alipay.trade.close")

    is_check =
      check_map_keys(params2["biz_content"], [
        "out_trade_no"
        #        "trade_no",  二选一
        #        "operator_id"
      ])
    is_legitimate = Enum.all?(params2["biz_content"],fn {_,v} -> is_binary(v)&&contains_special_characters?(v) end)
    response =
      if is_check && is_legitimate do
        params = %{
          #    notify_url: @notify_url,
          "biz_content" =>
            params2["biz_content"]
            |> Jason.encode!()
        }

        params = Map.merge(par, params)
        response = get_response(params)
        response = response.body |> Jason.decode!()
        response
      else
          if !is_legitimate do
            %{"msg_error" => "参数不合法"}
            else
            %{"msg_error" => "缺少参数"}
            end
      end

    json(con, response)
  end

  def trade_query(con, params2) do
    par = AlipayParams.json_params() |> Map.put("method", "alipay.trade.query")

    is_check =
      check_map_keys(params2["biz_content"], [
        "out_trade_no"
        #        "trade_no",  二选一
        #        "query_options",  非必选
      ])
    is_legitimate = Enum.all?(params2["biz_content"],fn {_,v} -> is_binary(v)&&contains_special_characters?(v) end)
    response =
      if is_check && is_legitimate do
        params = %{
          "biz_content" =>
            params2["biz_content"]
            |> Jason.encode!()
        }

        params = Map.merge(par, params)
        response = get_response(params)
        body = response.body |> Jason.decode!()
        body
      else
        if !is_legitimate do
          %{"msg_error" => "参数不合法"}
        else
          %{"msg_error" => "缺少参数"}
        end

      end

    json(con, response)
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

    sorted_params = map2sign_str(params)
    
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

    if verify_result == true do
      json(con, %{"verify_result" => "验签成功", "params" => params})
    else
      json(con, %{"verify_result" => "验签失败", "params" => params})
    end
  end

  #  http://localhost:4000/alipay_app?subject=大乐透&out_trade_no=70501111111S001111119&total_amount=9.00
  def alipay_app(con, params2) do
    par = AlipayParams.json_params() |> Map.put("method", "alipay.trade.app.pay")

    is_check =
      check_map_keys(params2["biz_content"], [
        "subject",
        "out_trade_no",
        "total_amount"
      ])
    is_legitimate = Enum.all?(params2["biz_content"],fn {_,v} -> is_binary(v)&&contains_special_characters?(v) end)
    result_map =
      if is_check && is_legitimate do
        params = %{
          #      notify_url: @notify_url,
          "biz_content" =>
            params2["biz_content"]
            |> Jason.encode!()
        }

        params = Map.merge(par, params)
        response = get_response(params)


        [{"Location", response_location}] =
          response.headers |> Enum.filter(fn {key, _} -> key == "Location" end)

        %{"url" => response_location}
      else
        if !is_legitimate do
          %{"msg_error" => "参数不合法"}
        else
          %{"msg_error" => "缺少参数"}
        end

      end

    json(con, result_map)


  end
  #  http://localhost:4000/redirectPay?subject=大乐透&out_trade_no=9091991&total_amount=9.00
  def alipay_refund_query(con, params2) do
    par = AlipayParams.json_params() |> Map.put("method", "alipay.trade.fastpay.refund.query")

    is_check =
      check_map_keys(params2["biz_content"], [
        "out_trade_no",
        #        "trade_no",  二选一
        # 退款请求号。请求退款接口时，传入的退款请求号，如果在退款请求时未传入，则该值为创建交易时的商户订单号。
        "out_request_no"
      ])
    is_legitimate = Enum.all?(params2["biz_content"],fn {_,v} -> is_binary(v)&&contains_special_characters?(v) end)
    response =
      if is_check && is_legitimate do
        params = %{
          "biz_content" =>
            params2["biz_content"]
            |> Jason.encode!()
        }

        params = Map.merge(par, params)
        response = get_response(params)
        response = response.body |> Jason.decode!()
        response
      else
        if !is_legitimate do
          %{"msg_error" => "参数不合法"}
        else
          %{"msg_error" => "缺少参数"}
        end

      end

    json(con, response)
  end

  #  def refund_card(con,params) do
  #
  #  end

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
    verify_result = RsaEx.verify(sorted_params, sing, pem_string)

    if verify_result == true do
      json(con, %{"verify_result" => "验签成功", "params" => params})
    else
      json(con, %{"verify_result" => "验签失败", "params" => params})
    end
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

    private_key = AlipayParams.get_private_key()

    signed_params = sign_params(sign_params, private_key)
    signed_params = url_encode_map_value(signed_params) |> map2sign_str
    url = "#{@app_gateway}?#{signed_params}"
    _response=  HTTPoison.get!(url, [{"Content-type", "application/json"}])
  end

  def map2sign_str(map) do
    map
    |> Map.to_list()
    |> Enum.sort(&(elem(&1, 0) <= elem(&2, 0)))
    |> Enum.map(&"#{elem(&1, 0)}=#{elem(&1, 1)}")
    |> Enum.join("&")
  end

  def contains_special_characters?(input) do
    re_result=Regex.scan(~r/[!@#\$%\^&\*\(\)\+={};:<>?\\|]/, input)
#    IO.inspect(re_result)
#    IO.inspect(input)
    case  re_result do
      [] -> true
      _ -> false
    end
  end
  def check_map_keys(map, keys) do
    if is_map(map) do
      Enum.all?(keys, &Map.has_key?(map, &1))
    else
      false
    end
  end
end

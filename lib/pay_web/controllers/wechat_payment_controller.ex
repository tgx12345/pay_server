defmodule WechatPaymentController do
  use PayWeb, :controller

  def place_order_native(conn, _params) do
<<<<<<< HEAD
    result = if WechatPay.checkout_place_order_map(conn.body_params) do
      response = WechatPay.place_an_order(0, conn.body_params)
      json(conn, response |>Jason.decode!)
      else
      json(conn,%{"message"=>"请检查参数的完整性和合法性"})
    end

=======
    response = WechatPay.place_an_order(0, conn.body_params)
    json(conn, response |>Jason.decode!)
>>>>>>> 50eb56214ed9ad49b97b5ae8e9fb2b6b2b3dbb6d
  end

  def callback(conn, _params) do
    valid = WechatPay.get_verify_decrypt_back(conn)
#    json(conn,valid)
    if valid == false do
      conn
      |> put_status(401)
      |> json(%{
        "code" => "FAIL",
        "message" => "回调失败"
      })
    else
      conn
      |> put_status(200)
      |> json(%{
        "code" => "SUCCESS",
        "message" => "回调成功"
      })
    end
  end

  def place_order_app(conn, _params) do
<<<<<<< HEAD
    result = if WechatPay.checkout_place_order_map(conn.body_params) do
      response = WechatPay.place_an_order(1,conn.body_params)
      json(conn, response |>Jason.decode!)
    else
      json(conn,%{"message"=>"请检查参数的完整性和合法性"})
    end
=======
    response = WechatPay.place_an_order(1,conn.body_params)
    json(conn, response |>Jason.decode!)
>>>>>>> 50eb56214ed9ad49b97b5ae8e9fb2b6b2b3dbb6d
  end

  def sel_out_trade_no(conn, _params) do
    response = WechatPay.sel_out_trade_no(conn.params)
    json(conn, response |>Jason.decode!)
  end

  def close_out_trade_no(conn, _params) do
    response = WechatPay.close_out_trade_no(conn.params)
    json(conn, response |>Jason.decode!)
  end

  def refund(conn, _params) do
<<<<<<< HEAD
    result = if WechatPay.checkout_refund_map(conn.body_params) do
      response = WechatPay.refund(conn.body_params)
      json(conn, response |>Jason.decode!)
    else
      json(conn,%{"message"=>"请检查退款参数的完整性和合法性"})
    end

=======
    response = WechatPay.refund(conn.params)
    json(conn, response |>Jason.decode!)
>>>>>>> 50eb56214ed9ad49b97b5ae8e9fb2b6b2b3dbb6d
  end

  def refund_select(conn, _params) do
    response = WechatPay.refund_select(123)
    json(conn, response |>Jason.decode!)
  end

  def test(conn, _params) do
   IO.inspect(conn)
   json(conn,false)

  end

end

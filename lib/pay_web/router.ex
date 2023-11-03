defmodule PayWeb.Router do
  use PayWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PayWeb.LayoutView, :root}
#    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/alipay" do
    pipe_through :api

        post "/app" , AlipayController, :alipay_app
        post "/refund_query" , AlipayController, :alipay_refund_query
        post "/verify_sign" , AlipayController, :verify_sign
        post "/trade_query" , AlipayController, :trade_query
        post "/close" , AlipayController, :close_alipay
        post "/refund" , AlipayController, :trade_refund
        post "/async_url" ,  AlipayController, :alipay_async_notice
        post "/redirect_pay", AlipayController, :start_pay
  end

  scope "/", PayWeb do
    pipe_through :browser
    get "/", PageController, :index
  end

  scope "/wx" do
    pipe_through :api
    post "/native", WxPaymentController, :place_order_native
    post "/app", WxPaymentController, :place_order_app
    post "/callback", WxPaymentController, :callback
    get "/select", WxPaymentController, :sel_out_trade_no
    get "/close", WxPaymentController, :close_out_trade_no
    post "/refund", WxPaymentController, :refund
    get "/refund_select", WxPaymentController, :refund_select
    get "/test", WxPaymentController, :test
  end

  # Other scopes may use custom stacks.
  # scope "/api", PayWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: PayWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

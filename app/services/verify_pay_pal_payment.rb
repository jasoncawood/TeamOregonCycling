class VerifyPayPalPayment < ApplicationService
  input :order_id
  input :error
  input :with_result, default: ->(result) { result }

  authorization_policy allow_all: true

  main do
    retrieve_order_details
    extract_payment_data
    run_callback with_result, result
  end

  private

  attr_accessor :response

  def retrieve_order_details
    self.response = GetOrder.call(order_id)

    return if response.status_code.to_s =~ /^2/

    logger.error '[PAYPAL ERROR] Unable to retrieve details for PayPal ' \
                 "order ID #{order_id}."

    error!(<<~MSG)
      We were unable to retrieve your order details from PayPal for the
      order ID #{order_id}. This may mean that your payment was processed by
      PayPal, but that there is a system problem with fetching the data. Please
      do *not* try another payment, as you may end up being double-charged.
      Contact us, and we will investigate the problem.
    MSG
  end

  def extract_payment_data
    self.result = response.result
  end

  def response_status
    response.status_code
  end

  def error!(message)
    run_callback(error, message)
    stop!
  end

  module GetOrder
    include PayPalCheckoutSdk::Orders

    extend self

    def call(order_id)
      request = OrdersGetRequest.new(order_id)
      PayPalClient.client.execute(request)
    end
  end
end

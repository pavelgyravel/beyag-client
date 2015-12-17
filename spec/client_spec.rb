require 'spec_helper'
require 'json'

RSpec.describe Beyag::Client do
  let(:client) { Beyag::Client.new("shop_id" => '1', "secret_key" => '123new') }

  let(:success_response) {
    {
      "transaction" => {
        "type" => "payment",
        "billing_address" => {
          "first_name" => "Иван",
          "last_name" => "Петров",
          "country" => "BY",
          "city" => "Пинск",
          "address" => "ул Червякова",
          "zip" => "220000",
          "phone" => "+375172000000"
        },
        "customer" => {
          "email" => "ivanpetrov@tut.by",
          "ip" => "127.0.0.8"
        },
        "payment" => {
          "ref_id" => nil,
          "message" => "Требование на оплату счета создано.",
          "status" => "pending",
          "gateway_id" => 479
        },
        "id" => "c7775662-aed8-44d0-839c-29468e9162fb",
        "uid" => "c7775662-aed8-44d0-839c-29468e9162fb",
        "order_id" => "123456789012",
        "status" => "pending",
        "message" => "Требование на оплату счета создано.",
        "amount" => 100,
        "currency" => "BYR",
        "description" => "Оплата заказа #3",
        "tracking_id" => "123456789012",
        "created_at" => "2015-12-15T13:22:11.116Z",
        "test" => true,
        "payment_method_type" => "erip",
        "erip" => {
          "request_id" => nil,
          "service_no" => 99999999,
          "account_number" => "321",
          "transaction_id" => nil,
          "instruction" => ["Платежи -> Минск -> Интернет магазины -> Доставка счастья"],
          "service_info" => ["Уважаемый Клиент", "Подтвердите оплату заказа №123"],
          "receipt" => ["Спасибо за оплату заказа №123, наши операторы свежутся с вами"]
        }
      }
    }
  }

  let(:failed_response) {
    {
      "message" => "Invalid shop_id/secret_key.",
      "errors" => { "system" => ["System error."] }
    }
  }

  describe '#payment' do
    let(:params) {
      {
        "amount" => 100,
        "currency" => "BYR",
        "description" => "Оплата заказа #3",
        "email" => "ivanpetrov@tut.by",
        "ip" => "127.0.0.8",
        "order_id" => 123456789012,
        "notification_url" =>  "http://merchant.example.com",
        "customer" => {
          "first_name" => "Иван",
          "last_name" => "Петров",
          "country" => "BY",
          "city" => "Пинск",
          "zip" => "220000",
          "address" => "ул Червякова",
          "phone" => "+375172000000"
        },
        "payment_method" => {
          "type" => "erip",
          "account_number" => "321", # вводит мерчант, 30 макс
          "service_no" => "99999999", # из gateway, может быть несколько
          "instruction" => ["Платежи -> Минск -> Интернет магазины -> Доставка счастья"], # введите номер заказа
          "service_info" => ["Уважаемый Клиент", "Подтвердите оплату заказа №123"], # номер заказа, договора
          "receipt" =>  ["Спасибо за оплату заказа №123, наши операторы свежутся с вами"] # что бы ты хотел показать на чеке
        }
      }
    }

    before {
      stub_request(:post, /api.bepaid.by\/beyag\/payment/).to_return(response_obj)
    }

    context 'success request' do
      let(:response_obj) { { body: success_response.to_json, status: 200 } }

      it 'gets pending response from ERIP' do
        response = client.payment(params)

        expect(response.successful?).to eq(true)
        expect(response.transaction["amount"]).to eq(100)
      end
    end

    context 'failed request' do
      let(:response_obj) { { body: failed_response.to_json, status: 401 } }

      it 'gets failed response from ERIP' do
        response = client.payment(params)

        expect(response.successful?).to eq(false)
      end
    end
  end

  describe '#query' do
    let(:order_id) { "bbb07d8b-eb16-40a3-97a7-7e52ae11c0e4" }

    before {
      stub_request(:get, /api.bepaid.by\/beyag\/payment/).to_return(response_obj)
    }

    context 'success request' do
      let(:response_obj) { { body: success_response.to_json, status: 200 } }

      it 'fetches order information' do
        response = client.query(order_id)

        expect(response.successful?).to eq(true)
        expect(response.transaction["amount"]).to eq(100)
      end
    end

    context 'failed request' do
      let(:response_obj) { { body: failed_response.to_json, status: 401 } }

      it 'gets failed response from ERIP' do
        response = client.query("")

        expect(response.successful?).to eq(false)
      end
    end
  end
end

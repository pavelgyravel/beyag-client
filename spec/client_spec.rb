require 'spec_helper'
require 'json'

RSpec.describe Beyag::Client do
  describe '#payment' do
    let(:client) { Beyag::Client.new("shop_id" => '1', "secret_key" => '123new') }
    let(:params) {
      {
        "amount":100,
        "currency":"BYR",
        "description":"Оплата заказа #3",
        "email":"ivanpetrov@tut.by",
        "ip":"127.0.0.8",
        "order_id":123456789012,
        "notification_url": "http://merchant.example.com",
        "customer":{ # опциональна
          "first_name":"Иван",
          "last_name":"Петров",
          "country":"BY",
          "city":"Пинск",
          "zip":"220000",
          "address":"ул Червякова",
          "phone":"+375172000000"
        },
        "payment_method":{
          "type":"beyag",
          "account_number":"321", # вводит мерчант, 30 макс
          "service_no":"654", # из gateway, может быть несколько
          "instruction":["Платежи -> Минск -> Интернет магазины -> Доставка счастья"], # введите номер заказа
          "service_info":["Уважаемый Клиент", "Подтвердите оплату заказа №123"], # номер заказа, договора
          "receipt": ["Спасибо за оплату заказа №123, наши операторы свежутся с вами"] # что бы ты хотел показать на чеке
        }
      }
    }

    before {
      stub_request(:post, /api.bepaid.by\/beyag\/payment/).to_return(response_obj)
    }

    context 'success request' do
      let(:response_obj) { { body: response.to_json, status: 200 } }
      let(:response) {
        {
          "response" => {
            "id" => "5fbc45bd-b45b-4171-8373-45fbf8646117",
            "state" => "pending",
            "amount" => "100",
            "currency" => "BYR",
            "description" => "Оплата заказа #123",
            "order_id" => 123456789012,
            "email" => "ivanpetrov@tut.by",
            "message" => 'pending',
            "created_at" => "2015-10-28T11:19:52.156Z",
            "updated_at" => "2015-10-28T11:19:52.188Z",
            "payment_method" => {
              "type" => "beyag",
              "account_number" => "321",
              "service_no" => "654",
              "instruction" => ["Платежи -> Минск -> Интернет магазины -> Доставка счастья"],
              "service_info" => ["Уважаемый Клиент", "введите номер заказа"],
              "receipt" => ["Спасибо за оплату, наши операторы свежутся с вами"]
            },
            "customer" => {
              "first_name" => "Иван",
              "last_name" => "Петров",
              "country" => "BY",
              "city" => "Пинск",
              "address" => "ул Червякова",
              "zip" => "220000",
              "phone" => "+375172000000"
            }
          }
        }
      }

      it 'gets pending response from ERIP' do
        response = client.payment(params)

        expect(response.successful?).to eq(true)
      end
    end

    context 'failed request' do
      let(:response_obj) { { body: response.to_json, status: 401 } }
      let(:response) {
        {
          "response" => {
            "message" => "Invalid shop_id/secret_key.",
            "errors" => { "system" => ["System error."] }
          }
        }
      }

      it 'gets failed response from ERIP' do
        response = client.payment(params)

        expect(response.successful?).to eq(false)
      end
    end
  end

end

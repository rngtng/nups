require 'spec_helper'

describe ChartsHelper do
  fixtures :users

  let(:account) {Account.create :user => users(:biff)}

  describe "newsletters_chart" do
    it "works" do
      puts helper.newsletters_chart(account.newsletters)
    end
  end

  describe "recipients_chart" do
    let(:time_group) { 1.day }
    let(:date) { Time.parse("2011-12-10 12:34:00 UTC") }
    let(:ago_4) { date - 4 * time_group }
    let(:ago_3) { date - 3 * time_group }
    let(:ago_2) { date - 2 * time_group }
    let(:ago_1) { date - 1 * time_group }

    let(:now_d) { Time.parse("2011-12-10 00:00:00 UTC") }
    let(:ago_4_d) { (now_d - 4 * time_group).to_i }
    let(:ago_3_d) { (now_d - 3 * time_group).to_i }
    let(:ago_2_d) { (now_d - 2 * time_group).to_i }
    let(:ago_1_d) { (now_d - 1 * time_group).to_i }

    let(:recipient_attrs) do
      [
        {:email => Faker::Internet.email, :state => 'pending',   :created_at => ago_4},
        {:email => Faker::Internet.email, :state => 'pending',   :created_at => ago_3 + 3.hours},
        {:email => Faker::Internet.email, :state => 'pending',   :created_at => ago_3, :updated_at => ago_2 + 2.hours},
        {:email => Faker::Internet.email, :state => 'confirmed', :created_at => ago_3},
        {:email => Faker::Internet.email, :state => 'confirmed', :created_at => ago_3, :updated_at => ago_2},
        {:email => Faker::Internet.email, :state => 'confirmed', :created_at => ago_2, :updated_at => ago_1},
        {:email => Faker::Internet.email, :state => 'deleted',   :created_at => ago_2, :updated_at => ago_2},
        {:email => Faker::Internet.email, :state => 'deleted',   :created_at => ago_2, :updated_at => ago_1},
      ]
    end

    let(:actual_result) { helper.recipients_chart(account) }
    let(:expected_result) do
      {
        :pending   => { ago_4_d => 1, ago_3_d => 2 },
        :confirmed => { ago_3_d => 2, ago_2_d => 2, ago_1_d => -1 },
        :deleted   => { ago_2_d => 1, ago_1_d => 1 },
      }
    end

    before do
      recipient_attrs.each do |recipient_attr|
        recipient = account.recipients.create(recipient_attr, :as => :test)
        recipient.update_attribute(:created_at, recipient_attr[:created_at])
        recipient.update_attribute(:updated_at, recipient_attr[:updated_at] || recipient_attr[:created_at])
      end
    end

    it "works for pending" do
      actual_result[:pending].to_a.should =~ expected_result[:pending].to_a
    end

    it "works for confirmed" do
      actual_result[:confirmed].to_a.should =~ expected_result[:confirmed].to_a
    end

    it "works for deleted" do
      actual_result[:deleted].to_a.should =~ expected_result[:deleted].to_a
    end
  end
end

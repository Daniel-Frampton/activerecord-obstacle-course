require 'rails_helper'

describe 'ActiveRecord Obstacle Course, Week 4' do

# Looking for your test setup data?
# It's currently inside /spec/rails_helper.rb
# Not a very elegant solution, but works for this iteration.

# Here are the docs associated with ActiveRecord queries: http://guides.rubyonrails.org/active_record_querying.html

# ----------------------


  it '21. calculates the total sales' do
    # ---------------------- Using Ruby -------------------------
    # total_sales = Order.all.map(&:amount).inject(:+)
    # -----------------------------------------------------------

    # ------------------ Using ActiveRecord ---------------------
    total_sales = Order.sum(:amount)
    # -----------------------------------------------------------

    # Expectation
    expect(total_sales).to eq(9750)
  end

  it '22. calculates the total sales for all but one user' do
    # # ---------------------- Using Ruby -------------------------
    # orders = Order.select do |order|
    #   order.user_id != @user_2.id
    # end

    # total_sales = orders.map(&:amount).inject(:+)
    # -----------------------------------------------------------

    # ------------------ Using ActiveRecord ---------------------
    total_sales = Order.where.not(user_id: @user_2.id).sum(:amount)
    # -----------------------------------------------------------

    # Expectation
    expect(total_sales).to eq(6500)
  end

  it '23. returns all orders which include item_4' do
    expected_result = [@order_3, @order_11, @order_5, @order_13, @order_10, @order_15, @order_9]

    # # ------------------ Inefficient Solution -------------------
    # order_ids = OrderItem.where(item_id: @item_4.id).map(&:order_id)

    # orders = order_ids.map { |id| Order.find(id) }
    # -----------------------------------------------------------

    # ------------------ Improved Solution ----------------------
    # return orders
    # criteria is item ID

    orders = Order.joins(:order_items).where(order_items: { item: @item_4 })
    # -----------------------------------------------------------

    # Expectation
    expect(orders).to eq(expected_result)
  end

  it '24. returns all orders for user 2 which include item_4' do
    expected_result = [@order_11, @order_5]

    # ------------------ Inefficient Solution -------------------
    # orders = Order.where(user: @user_2)

    # order_ids = OrderItem.where(order_id: orders, item: @item_4).pluck(:order_id)

    # orders = order_ids.map { |id| Order.find(id) }
    # # -----------------------------------------------------------

    # ------------------ Improved Solution ----------------------
    #  Solution goes here
    
    orders = Order.joins(:order_items)
                  .where(order_items: { item: @item_4 })
                  .where(user: @user_2)
    # -----------------------------------------------------------

    # Expectation
    expect(orders).to eq(expected_result)
  end

  it '25. returns items that are associated with one or more orders' do
    unordered_item = Item.create(name: 'Unordered Item')
    expected_result = [@item_1, @item_4, @item_9, @item_2, @item_5, @item_10, @item_3, @item_8, @item_7]

    # ----------------------- Using Ruby -------------------------
    # items = Item.all

    # ordered_items = items.select do |item|
    #   item.orders.present?
    # end
    # ------------------------------------------------------------

    # ------------------ ActiveRecord Solution ----------------------
    # ordered_items = Item.where.not(id: OrderItem.select(:item_id))
    ordered_items = Item.joins(:order_items).group_by(:id)
    # ordered_items = Item.joins(:orders).distinct
    # ---------------------------------------------------------------

    # Expectations
    expect(ordered_items).to eq(expected_result)
    expect(ordered_items).to_not include(unordered_item)
  end
end

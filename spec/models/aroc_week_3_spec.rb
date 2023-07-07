require 'rails_helper'

describe 'ActiveRecord Obstacle Course, Week 3' do

# Looking for your test setup data?
# It's currently inside /spec/rails_helper.rb
# Not a very elegant solution, but works for this iteration.

# Here are the docs associated with ActiveRecord queries: http://guides.rubyonrails.org/active_record_querying.html

# ----------------------


  it '16. returns the names of users who ordered one specific item' do
    expected_result = [@user_2.name, @user_3.name, @user_1.name]

    # ----------------------- Using Raw SQL-----------------------
    # users = ActiveRecord::Base.connection.execute("
    #   select
    #     distinct users.name
    #   from users
    #     join orders on orders.user_id=users.id
    #     join order_items ON order_items.order_id=orders.id
    #   where order_items.item_id=#{@item_8.id}
    #   ORDER BY users.name")
    # users = users.map {|u| u['name']}
    # ------------------------------------------------------------

    # ------------------ Using ActiveRecord ----------------------
    users = User.joins(:order_items).where(order_items: { item_id: @item_8.id }).distinct.pluck(:name)
    # users = OrderItem.joins(order: :user).where(item_id: @item_8.id).distinct.pluck(:name)
    # ------------------------------------------------------------

    # Expectation
    expect(users).to eq(expected_result)
  end

  it '17. returns the name of items associated with a specific order' do
    expected_result = ['Abercrombie', 'Giorgio Armani', 'J.crew', 'Fox']

    # ----------------------- Using Ruby -------------------------
    # last_order = Order.last
    # last_order_items = last_order.items.all
    # item_names = last_order_items.map(&:name) O(n)
    # names = Order.last.items.all.map(&:name)
    # ------------------------------------------------------------

    # ------------------ Using ActiveRecord ----------------------
    names = Item.joins(:order_items)
      .where(order_items: { order_id: Order.order(id: :desc).limit(1) })
      .pluck(:name)
    # ------------------------------------------------------------

    # Expectation
    expect(names.sort).to eq(expected_result.sort)
  end

  it '18. returns the names of items for a users order' do
    expected_result = ['Giorgio Armani', 'Banana Republic', 'Izod', 'Fox']

    # ----------------------- Using Ruby -------------------------
    # user_3_orders = Order.all.select do |order|
    #   order.items && order.user_id == @user_3.id
    # end
    # items_for_user_3_third_order = user_3_orders[2].items.map(&name)
    # ------------------------------------------------------------

    # ------------------ Using ActiveRecord ----------------------
    # For reference, this is what it looks like as 2 separate queries:
    # user_3_third_order = Order.where(user: @user_3).limit(1).offset(2).first
    # items_for_user_3_third_order = user_3_third_order.items.pluck(:name)

    items_for_user_3_third_order = Item.joins(:order_items).where(order_items: { order_id: Order.where(user: @user_3).limit(1).offset(2) } ).pluck(:name)
    # ------------------------------------------------------------

    # Expectation
    expect(items_for_user_3_third_order.sort).to eq(expected_result.sort)
  end

  it '19. returns the average amount for all orders' do
    # ---------------------- Using Ruby -------------------------
    # amounts = Order.all.map(&:amount)
    
    # total = amounts.reduce(0) do |accumulator, amount|
    #   accumulator + amount
    # end
    
    # average = total / (Order.count)
    # -----------------------------------------------------------

    # ------------------ Using ActiveRecord ----------------------
    average = Order.average(:amount)
    # ------------------------------------------------------------

    # Expectation
    expect(average).to eq(650)
  end

  it '20. returns the average amount for all orders for one user' do
    # ---------------------- Using Ruby -------------------------
    # orders = Order.all.select do |order|
    #   order if order.user_id == @user_3.id
    # end
    
    # average = (orders.map(&:amount).reduce(:+)) / (orders.count)
    # -----------------------------------------------------------

    # ------------------ Using ActiveRecord ----------------------
    average = Order.where(user_id: @user_3.id).average(:amount)
    # ------------------------------------------------------------

    # Expectation
    expect(average.to_i).to eq(749)
  end
end

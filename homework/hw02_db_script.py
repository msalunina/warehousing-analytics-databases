import pandas as pd
import dataset

def create_table(df, columns):
    table = df[columns].copy()
    table = table.drop_duplicates().reset_index(drop=True)
    table = table.astype(object).where((pd.notnull(table)), None)
    return table


# EXTRACT
data_base = dataset.connect("postgresql://postgres@localhost/data_base_hw01")
products = pd.DataFrame(data=list(data_base['products'].all()))
offices = pd.DataFrame(data=list(data_base['offices'].all()))
employees = pd.DataFrame(data=list(data_base['employees'].all()))
customers = pd.DataFrame(data=list(data_base['customers'].all()))
orders = pd.DataFrame(data=list(data_base['orders'].all()))
items = pd.DataFrame(data=list(data_base['items'].all()))


# TRANSFORM

## orders
items_ = create_table(items, ['order_number', 'order_line_number'])
orders_ = create_table(orders, ['order_number', 'status', 'comments'])
orders_table = items_.merge(orders_, how='left', on='order_number')

## products
products_table = create_table(products, ['product_code', 'product_line', 'product_name', 'product_scale',
                                         'product_vendor', 'product_description', 'html_description'])

## customers
customers_table = create_table(customers, ['customer_number', 'customer_name', 'contact_last_name',
                                           'contact_first_name',  'city', 'state', 'country', 'customer_location'])

## dates
orders['order_date'] = pd.to_datetime(orders['order_date'])
orders['required_date'] = pd.to_datetime(orders['required_date'])
orders['shipped_date'] = pd.to_datetime(orders['shipped_date'])
min_date = min([min(orders.order_date), min(orders.required_date), min(orders.shipped_date)])
max_date = max([max(orders.order_date), max(orders.required_date), max(orders.shipped_date)])
dates_table = pd.DataFrame(pd.date_range(min_date, max_date, freq='D'), columns=['full_date'])
dates_table['date_year'] = dates_table['full_date'].dt.year
dates_table['date_month'] = dates_table['full_date'].dt.month
dates_table['date_day'] = dates_table['full_date'].dt.day
dates_table['date_quarter'] = dates_table['full_date'].dt.quarter
dates_table['date_week'] = dates_table['full_date'].dt.week
dates_table['date_weekday'] = dates_table['full_date'].dt.weekday_name
dates_table = create_table(dates_table, dates_table.columns)

## employees
employees_table = create_table(employees, ['employee_number', 'last_name', 'first_name', 'job_title'])

## offices
offices_table = create_table(offices, offices.columns)

## profit
profit_table = items[['order_number', 'order_line_number', 'quantity_ordered', 'price_each', 'product_code']].copy()
profit_table = profit_table.merge(products[['product_code', 'quantity_in_stock', 'buy_price', '_m_s_r_p']],
                                  how='left', on='product_code')
profit_table = profit_table.merge(orders[['order_number', 'order_date', 'required_date', 'shipped_date',
                                         'sales_rep_employee_number', 'customer_number']],
                                  how='left', on='order_number')
profit_table = profit_table.merge(employees[['employee_number', 'reports_to', 'office_code']], how='left',
                                  left_on='sales_rep_employee_number', right_on='employee_number')
profit_table.reports_to = profit_table.reports_to.astype(float).astype(int)
del profit_table['employee_number']
profit_table = profit_table.merge(customers[['customer_number', 'credit_limit']],
                                  how='left', on='customer_number')
for column in ['price_each', 'buy_price', '_m_s_r_p', 'credit_limit']:
    profit_table[column] = profit_table[column].str.replace('$', '').str.replace(',', '')
    profit_table[column] = profit_table[column].astype(float)
profit_table['revenue'] = profit_table['quantity_ordered'] * profit_table['price_each']
profit_table['cogs'] = profit_table['quantity_ordered'] * profit_table['buy_price']
profit_table['profit'] = profit_table['revenue'] - profit_table['cogs']
profit_table['profit_margin'] = profit_table['profit'] / profit_table['revenue']
profit_table = create_table(profit_table, profit_table.columns)


# LOAD
data_base_star = dataset.connect("postgresql://postgres@localhost/data_base_hw02")

orders = data_base_star['orders']
products = data_base_star['products']
customers = data_base_star['customers']
dates = data_base_star['dates']
employees = data_base_star['employees']
offices = data_base_star['offices']
profit = data_base_star['profit']

orders.insert_many(orders_table.to_dict('records'))
products.insert_many(products_table.to_dict('records'))
customers.insert_many(customers_table.to_dict('records'))
dates.insert_many(dates_table.to_dict('records'))
employees.insert_many(employees_table.to_dict('records'))
offices.insert_many(offices_table.to_dict('records'))
profit.insert_many(profit_table.to_dict('records'))

data_base.commit()
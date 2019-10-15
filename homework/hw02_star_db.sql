DROP DATABASE data_base_hw02;
CREATE DATABASE data_base_hw02;
\c data_base_hw02;

CREATE TABLE orders (
        order_number INTEGER,
        order_line_number INTEGER,
        status VARCHAR,
        comments VARCHAR,
        PRIMARY KEY (order_number, order_line_number)
);

CREATE TABLE products (
        product_code VARCHAR PRIMARY KEY,
        product_line VARCHAR,
        product_name VARCHAR,
        product_scale VARCHAR,
        product_vendor VARCHAR,
        product_description VARCHAR,
        html_description VARCHAR
);

CREATE TABLE customers (
        customer_number INTEGER PRIMARY KEY,
        customer_name VARCHAR,
        contact_last_name VARCHAR,
        contact_first_name VARCHAR,
        city VARCHAR,
        state VARCHAR,
        country VARCHAR,
        customer_location VARCHAR
);

CREATE TABLE dates (
        full_date DATE PRIMARY KEY,
        date_year INTEGER,
        date_month INTEGER,
        date_day INTEGER,
        date_quarter INTEGER,
        date_week INTEGER,
        date_weekday VARCHAR
);

CREATE TABLE employees (
        employee_number INTEGER PRIMARY KEY,
        last_name VARCHAR,
        first_name VARCHAR,
        job_title VARCHAR
);

CREATE TABLE offices (
        office_code INTEGER PRIMARY KEY,
        city VARCHAR,
        state VARCHAR,
        country VARCHAR,
        office_location VARCHAR
);

CREATE TABLE profit (
        -- orders
        order_number INTEGER,
        order_line_number INTEGER,
        FOREIGN KEY (order_number, order_line_number) REFERENCES orders (order_number, order_line_number),
        quantity_ordered INTEGER,
        price_each MONEY,

        -- products
        product_code VARCHAR REFERENCES products(product_code),
        quantity_in_stock INTEGER,
        buy_price MONEY,
        _m_s_r_p MONEY,

        -- customers
        customer_number INTEGER REFERENCES customers(customer_number),
        credit_limit MONEY,

        -- dates
        order_date DATE REFERENCES dates(full_date),
        required_date DATE REFERENCES dates(full_date),
        shipped_date DATE REFERENCES dates(full_date),

        -- employees
        sales_rep_employee_number INTEGER REFERENCES employees(employee_number),
        reports_to INTEGER REFERENCES employees(employee_number),

        -- offices
        office_code INTEGER REFERENCES offices(office_code),

        -- additional measures
        revenue MONEY,      -- quantity_ordered * price_each
        cogs MONEY,         -- quantity_ordered * buy_price
        profit MONEY,       -- revenue - cogs
        profit_margin REAL, -- profit / revenue

        PRIMARY KEY (order_number, order_line_number)
);





Data Dictionary for Gold Layer

**Table 1:**
**gold.dim_customers

This table stores customers details 

| Column Name     | Data Type     | Description                                                                 |
|-----------------|--------------|-----------------------------------------------------------------------------|
| customer_key    | INT          | Primary key that identifies each customer. |
| customer_id     | INT          | Numerical identifier assigned to each customer.                      |
| customer_number | NVARCHAR(50) | Alphanumeric identifier that represents the customer.|
| first_name      | NVARCHAR(50) | The customer's first name.   |
| last_name       | NVARCHAR(50) | The customer's last name .                                |
| country         | NVARCHAR(50) | The country of residence for the customer.          |
| marital_status  | NVARCHAR(50) | The marital status of the customer.          |
| gender          | NVARCHAR(50) | The gender of the customer.               |
| birthdate       | DATE         | The date of birth of the customer stored in the YYYY-MM-DD format. |
| create_date     | DATE         | The date and time when the customer record was made in the system.       |

## Data Dictionary for Gold Layer

**Table 2:**
**gold.dim_products**

This table stores product details 

| Column Name         | Data Type     | Description                                                                 |
|---------------------|--------------|-----------------------------------------------------------------------------|
| product_key         | INT          | Primary key uniquely identifying each product. |
| product_id          | INT          | A unique identifier assigned to each product. |
| product_number      | NVARCHAR(50) | An alphanumerical code representing the product. |
| product_name        | NVARCHAR(50) | Descriptive name of the product. |
| category_id         | NVARCHAR(50) | A unique identifier for the product's category. |
| category            | NVARCHAR(50) | The broader classification of the product. |
| subcategory         | NVARCHAR(50) | A more detailed classification of the product. |
| maintenance_required| NVARCHAR(50) | Shows if the product requires maintenance (e.g., 'Yes', 'No'). |
| cost                | INT          | The cost or base price of the product. |
| product_line        | NVARCHAR(50) | The specific product line or series to which the product belongs. |
| start_date          | DATE         | The date when the product became available for sale. |

## Data Dictionary for Gold Layer

**Table 3:**
**gold.fact_sales**

This Table stores transaction data for analaytical purposes.

| Column Name   | Data Type     | Description                                                                 |
|---------------|--------------|-----------------------------------------------------------------------------|
| order_number  | NVARCHAR(50) | A unique alphanumerical value for each sales order. |
| product_key   | INT          | Foreign key linking the order to the product dimension table. |
| customer_key  | INT          | Foreign key linking the order to the customer dimension table. |
| order_date    | DATE         | The date when the order was placed. |
| shipping_date | DATE         | The date when the order was shipped. |
| due_date      | DATE         | The date when the order payment was due. |
| sales_amount  | INT          | The total value of the sale for the item. |
| quantity      | INT          | The number of units of the product ordered. |
| price         | INT          | The price per unit of the product. |

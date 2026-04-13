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

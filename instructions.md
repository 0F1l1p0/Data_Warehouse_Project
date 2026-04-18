==========================================
HOW TO RUN THE PROJECT
==========================================
For the project you will need MSSQL Server Management Studio 
(For this specific project the 2021 version was used, although other newer versions work too)
Within the project each script will have an explanation commented within the code and additional

1.Download the datasets folder which you will need for the project

2.Within the scripts folder you will see a file called 'initialization.sql' run that folder in your version of 
MSSQL Server Management Studio 

3.After running said script, you will find within the scripts folder a 'bronze_layer' folder that contains a script called ddl_script.SQL and run it
3.1 After that Run the proc_insert_bronze.SQL script (IMPORTANT: in the proc_insert_bronze script you will need to change the FROM 'PATH' to the path
where you downloaded the files on your system, you will need to do this 6 times in the script, for the 6 seperate tables)

4.Within the silver_layer folder you will see a script called ddl_script and proc_insert_silver. Run both of those , first the ddl_script then the
proc_insert_silver script (To see how the data was inserted, refer to the tests folder and the quality_checks_silver script which shows examples
of testing the data for certain imperfections and mistakes)

5.Run the ddl_script which is found in the gold_layer folder (The tests folder contains quality_checks_gold.SQL which can show how the quality checks
have been done for the gold_layer)

ADDITIONAL INFORMATION: The docs folder contains images showing the information regarding the data(where it comes from, how its seperated, managed and corrected)
